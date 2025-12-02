-- ============================================
-- MATERIALIZUOTOS VIRTUALIOSIOS LENTELĖS
-- Laboratorinis darbas (atliekamas poroje)
-- Autoriai: [Jūsų vardai]
-- Data: 2025-01-24
-- ============================================

SET search_path TO "$user";

-- ============================================
-- MATERIALIZED VIEW KŪRIMAS
-- Poroje reikia bent 2 materializuotos VIEW
-- ============================================

-- --------------------------------------------
-- 1. Narių pajamų analizė (materializuota)
-- --------------------------------------------
-- Ši statistika skaičiuojama retai, bet naudojama dažnai,
-- todėl verta materializuoti

DROP MATERIALIZED VIEW IF EXISTS mv_nariu_pajamu_analize CASCADE;

CREATE MATERIALIZED VIEW mv_nariu_pajamu_analize AS
SELECT 
    n.narioid,
    n.vardas,
    n.pavarde,
    n.el_pastas,
    COUNT(DISTINCT a.abonementoid) AS abonementu_skaicius,
    COUNT(m.mokejimoid) AS mokejimo_kartu,
    SUM(m.kaina) AS bendra_suma,
    ROUND(AVG(m.kaina), 2) AS vidutinis_mokejimas,
    MIN(m.data) AS pirmas_mokejimas,
    MAX(m.data) AS paskutinis_mokejimas,
    STRING_AGG(DISTINCT a.tipas, ', ' ORDER BY a.tipas) AS abonementu_tipai
FROM NARYS n
LEFT JOIN ABONEMENTAS a ON n.narioid = a.narioid
LEFT JOIN MOKEJIMAS m ON a.abonementoid = m.abonementoid
WHERE m.statusas = 'Apmokėta'
GROUP BY n.narioid, n.vardas, n.pavarde, n.el_pastas
HAVING SUM(m.kaina) > 0
ORDER BY bendra_suma DESC;

COMMENT ON MATERIALIZED VIEW mv_nariu_pajamu_analize IS 
'Materializuota statistika apie narių mokėjimus ir pajamas - reikia atnaujinti periodiškai su REFRESH';

-- Sukurti indeksą materializuotai VIEW
CREATE INDEX idx_mv_pajamos_narioid ON mv_nariu_pajamu_analize(narioid);
CREATE INDEX idx_mv_pajamos_suma ON mv_nariu_pajamu_analize(bendra_suma DESC);

-- --------------------------------------------
-- 2. Treniruočių populiarumo reitingai (materializuota)
-- --------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS mv_treniruociu_populiarumas CASCADE;

CREATE MATERIALIZED VIEW mv_treniruociu_populiarumas AS
SELECT 
    tr.treniruotesid,
    tr.pavadinimas,
    tr.tipas,
    tr.sudetingumo_lygis,
    COUNT(DISTINCT s.sesijos_nr) AS sesiju_skaicius,
    COUNT(DISTINCT d.narioid) AS unikaliu_dalyviu_skaicius,
    SUM(CASE WHEN d.statusas = 'Dalyvavo' THEN 1 ELSE 0 END) AS bendras_dalyvavimo_skaicius,
    SUM(CASE WHEN d.statusas = 'Nedalyvavo' THEN 1 ELSE 0 END) AS nedalyvavimo_skaicius,
    ROUND(
        SUM(CASE WHEN d.statusas = 'Dalyvavo' THEN 1 ELSE 0 END)::NUMERIC / 
        NULLIF(COUNT(d.narioid), 0) * 100,
        2
    ) AS dalyvavimo_procentas,
    ROUND(AVG(d.ivertinimas), 2) AS vidutinis_ivertinimas,
    COUNT(d.ivertinimas) AS ivertinimu_skaicius,
    ROUND(AVG(s.uzsiregistravusiu_dalyviu_skaicius::NUMERIC), 1) AS vidutinis_uzsiregistravusiu_skaicius
FROM TRENIRUOTE tr
LEFT JOIN SESIJA s ON tr.treniruotesid = s.treniruotesid
LEFT JOIN DALYVAVIMAS d ON s.treniruotesid = d.treniruotesid 
    AND s.sesijos_nr = d.sesijos_nr
GROUP BY tr.treniruotesid, tr.pavadinimas, tr.tipas, tr.sudetingumo_lygis
ORDER BY vidutinis_ivertinimas DESC NULLS LAST, unikaliu_dalyviu_skaicius DESC;

COMMENT ON MATERIALIZED VIEW mv_treniruociu_populiarumas IS 
'Materializuota statistika apie treniruočių populiarumą pagal dalyvius, įvertinimus ir lankymą';

-- Sukurti indeksus materializuotai VIEW
CREATE INDEX idx_mv_populiarumas_treniruoteid ON mv_treniruociu_populiarumas(treniruotesid);
CREATE INDEX idx_mv_populiarumas_ivertinimas ON mv_treniruociu_populiarumas(vidutinis_ivertinimas DESC);

-- --------------------------------------------
-- 3. Mėnesio finansinė suvestinė (materializuota)
-- --------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS mv_menesio_finansai CASCADE;

CREATE MATERIALIZED VIEW mv_menesio_finansai AS
SELECT 
    TO_CHAR(m.data, 'YYYY-MM') AS metai_menuo,
    EXTRACT(YEAR FROM m.data) AS metai,
    EXTRACT(MONTH FROM m.data) AS menuo,
    COUNT(DISTINCT m.mokejimoid) AS mokejimo_skaicius,
    COUNT(DISTINCT m.abonementoid) AS apmokestu_abonementu_skaicius,
    COUNT(DISTINCT a.narioid) AS mokejusiu_nariu_skaicius,
    SUM(m.kaina) AS bendros_pajamos,
    ROUND(AVG(m.kaina), 2) AS vidutinis_mokejimas,
    STRING_AGG(DISTINCT m.budas, ', ' ORDER BY m.budas) AS mokejimo_budai,
    SUM(CASE WHEN m.budas = 'Kortelė' THEN m.kaina ELSE 0 END) AS pajamos_kortele,
    SUM(CASE WHEN m.budas = 'Grynais' THEN m.kaina ELSE 0 END) AS pajamos_grynais,
    SUM(CASE WHEN m.budas = 'Banko pavedimu' THEN m.kaina ELSE 0 END) AS pajamos_pavedimu
FROM MOKEJIMAS m
JOIN ABONEMENTAS a ON m.abonementoid = a.abonementoid
WHERE m.statusas = 'Apmokėta'
GROUP BY metai_menuo, metai, menuo
ORDER BY metai DESC, menuo DESC;

COMMENT ON MATERIALIZED VIEW mv_menesio_finansai IS 
'Materializuota mėnesio finansinė ataskaita - naudojama ataskaitoms';

CREATE INDEX idx_mv_finansai_metai_menuo ON mv_menesio_finansai(metai, menuo);

-- ============================================
-- REFRESH SAKINIAI
-- ============================================

\echo '================================================'
\echo 'Materializuotos VIEW sukurtos!'
\echo 'Dabar atnaujinami duomenys...'
\echo '================================================'

-- Atnaujinti visas materializuotas VIEW
REFRESH MATERIALIZED VIEW mv_nariu_pajamu_analize;
REFRESH MATERIALIZED VIEW mv_treniruociu_populiarumas;
REFRESH MATERIALIZED VIEW mv_menesio_finansai;

\echo 'Visi duomenys atnaujinti!'
\echo ''

-- ============================================
-- TESTAVIMAS
-- ============================================

\echo '--- Narių pajamų analizė ---'
SELECT * FROM mv_nariu_pajamu_analize LIMIT 5;

\echo ''
\echo '--- Treniruočių populiarumas ---'
SELECT * FROM mv_treniruociu_populiarumas LIMIT 5;

\echo ''
\echo '--- Mėnesio finansai ---'
SELECT * FROM mv_menesio_finansai;
