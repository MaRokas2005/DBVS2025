-- ============================================
-- VIRTUALIOSIOS LENTELĖS (VIEW)
-- Laboratorinis darbas (atliekamas poroje)
-- Autoriai: [Jūsų vardai]
-- Data: 2025-01-24
-- ============================================

SET search_path TO "$user";

-- ============================================
-- VIEW KŪRIMAS
-- Poroje reikia bent 4 VIEW
-- ============================================

-- --------------------------------------------
-- 1. Aktyvių narių su abonementais peržiūra
-- --------------------------------------------
CREATE OR REPLACE VIEW v_aktyvus_nariai AS
SELECT 
    n.narioid,
    n.vardas,
    n.pavarde,
    n.el_pastas,
    n.telefonas,
    a.tipas AS abonamento_tipas,
    a.pradzios_data,
    a.pabaigos_data,
    a.kaina AS abonamento_kaina,
    a.statusas AS abonamento_statusas
FROM NARYS n
JOIN ABONEMENTAS a ON n.narioid = a.narioid
WHERE a.statusas = 'Aktyvus'
ORDER BY n.pavarde, n.vardas;

COMMENT ON VIEW v_aktyvus_nariai IS 
'Rodo visus narius su aktyviais abonementais';

-- --------------------------------------------
-- 2. Būsimų sesijų tvarkaraštis
-- --------------------------------------------
CREATE OR REPLACE VIEW v_busimos_sesijos AS
SELECT 
    s.treniruotesid,
    s.sesijos_nr,
    tr.pavadinimas AS treniruotes_pavadinimas,
    tr.tipas AS treniruotes_tipas,
    s.data,
    s.pradzios_laikas,
    s.pabaigos_laikas,
    t.vardas || ' ' || t.pavarde AS trenerio_vardas,
    sa.pavadinimas AS sales_pavadinimas,
    s.uzsiregistravusiu_dalyviu_skaicius,
    tr.maksimalus_dalyviu_skaicius,
    (tr.maksimalus_dalyviu_skaicius - s.uzsiregistravusiu_dalyviu_skaicius) AS laisvos_vietos
FROM SESIJA s
JOIN TRENIRUOTE tr ON s.treniruotesid = tr.treniruotesid
LEFT JOIN TRENERIS t ON s.trenerisid = t.trenerisid
LEFT JOIN SALE sa ON s.salesid = sa.salesid
WHERE s.data >= CURRENT_DATE AND s.statusas = 'Suplanuota'
ORDER BY s.data, s.pradzios_laikas;

COMMENT ON VIEW v_busimos_sesijos IS 
'Rodo visas būsimas suplanuotas treniruočių sesijas su informacija apie trenerius, sales ir laisvas vietas';

-- --------------------------------------------
-- 3. Trenerių darbo krūvis
-- --------------------------------------------
CREATE OR REPLACE VIEW v_treneriu_kruviai AS
SELECT 
    t.trenerisid,
    t.vardas,
    t.pavarde,
    t.specializacija,
    COUNT(DISTINCT ts.sesijos_nr) AS sesiju_skaicius,
    COUNT(DISTINCT d.narioid) AS apmokytu_nariu_skaicius,
    ROUND(AVG(d.ivertinimas), 2) AS vidutinis_ivertinimas
FROM TRENERIS t
LEFT JOIN TRENERIS_SESIJA ts ON t.trenerisid = ts.trenerisid
LEFT JOIN SESIJA s ON ts.treniruotesid = s.treniruotesid 
    AND ts.sesijos_nr = s.sesijos_nr
LEFT JOIN DALYVAVIMAS d ON s.treniruotesid = d.treniruotesid 
    AND s.sesijos_nr = d.sesijos_nr
    AND d.statusas = 'Dalyvavo'
GROUP BY t.trenerisid, t.vardas, t.pavarde, t.specializacija
ORDER BY sesiju_skaicius DESC;

COMMENT ON VIEW v_treneriu_kruviai IS 
'Rodo kiekvieno trenerio darbo krūvį: sesijų skaičių, apmokytų narių skaičių ir vidutinius įvertinimus';

-- --------------------------------------------
-- 4. Narių lankomumo statistika
-- --------------------------------------------
CREATE OR REPLACE VIEW v_nariu_lankomumas AS
SELECT 
    n.narioid,
    n.vardas,
    n.pavarde,
    n.el_pastas,
    COUNT(d.treniruotesid) AS uzsiregistravo_kartu,
    SUM(CASE WHEN d.statusas = 'Dalyvavo' THEN 1 ELSE 0 END) AS dalyvavo_kartu,
    SUM(CASE WHEN d.statusas = 'Nedalyvavo' THEN 1 ELSE 0 END) AS nedalyvavo_kartu,
    ROUND(
        SUM(CASE WHEN d.statusas = 'Dalyvavo' THEN 1 ELSE 0 END)::NUMERIC / 
        NULLIF(COUNT(d.treniruotesid), 0) * 100, 
        2
    ) AS lankomumo_procentas,
    ROUND(AVG(d.ivertinimas), 2) AS vidutinis_ivertinimas
FROM NARYS n
LEFT JOIN DALYVAVIMAS d ON n.narioid = d.narioid
GROUP BY n.narioid, n.vardas, n.pavarde, n.el_pastas
HAVING COUNT(d.treniruotesid) > 0
ORDER BY lankomumo_procentas DESC NULLS LAST;

COMMENT ON VIEW v_nariu_lankomumas IS 
'Rodo kiekvieno nario lankymosi statistiką: registracijų skaičių, dalyvavimų skaičių, procentą ir vidutinius įvertinimus';

-- --------------------------------------------
-- 5. Pajamų suvestinė pagal abonementų tipus
-- --------------------------------------------
CREATE OR REPLACE VIEW v_pajamos_pagal_tipą AS
SELECT 
    a.tipas AS abonamento_tipas,
    COUNT(a.abonementoid) AS abonementu_skaicius,
    SUM(m.kaina) AS bendros_pajamos,
    ROUND(AVG(m.kaina), 2) AS vidutine_kaina,
    MIN(m.kaina) AS minimalus_mokejimas,
    MAX(m.kaina) AS maksimalus_mokejimas
FROM ABONEMENTAS a
JOIN MOKEJIMAS m ON a.abonementoid = m.abonementoid
WHERE m.statusas = 'Apmokėta'
GROUP BY a.tipas
ORDER BY bendros_pajamos DESC;

COMMENT ON VIEW v_pajamos_pagal_tipą IS 
'Rodo pajamų statistiką pagal abonementų tipus';

-- --------------------------------------------
-- 6. Salių užimtumas
-- --------------------------------------------
CREATE OR REPLACE VIEW v_saliu_uzimtumas AS
SELECT 
    sa.salesid,
    sa.pavadinimas,
    sa.sales_tipas,
    sa.maksimali_talpa,
    COUNT(s.sesijos_nr) AS sesiju_skaicius,
    SUM(s.uzsiregistravusiu_dalyviu_skaicius) AS bendras_dalyviu_skaicius,
    ROUND(
        AVG(s.uzsiregistravusiu_dalyviu_skaicius::NUMERIC / sa.maksimali_talpa * 100), 
        2
    ) AS vidutinis_uzimtumas_procentais
FROM SALE sa
LEFT JOIN SESIJA s ON sa.salesid = s.salesid
GROUP BY sa.salesid, sa.pavadinimas, sa.sales_tipas, sa.maksimali_talpa
ORDER BY vidutinis_uzimtumas_procentais DESC NULLS LAST;

COMMENT ON VIEW v_saliu_uzimtumas IS 
'Rodo salių užimtumo statistiką: sesijų skaičių ir vidutinius užimtumo procentus';

-- ============================================
-- VIEW TESTAVIMAS
-- ============================================

\echo '================================================'
\echo 'Virtualiosios lentelės (VIEW) sukurtos sėkmingai!'
\echo '================================================'

-- Parodyti visas VIEW
SELECT 
    schemaname,
    viewname
FROM pg_views
WHERE schemaname = '$user'
ORDER BY viewname;

\echo ''
\echo 'Pavyzdiniai duomenys iš VIEW:'
\echo ''
\echo '--- Aktyvūs nariai (pirmi 5) ---'
SELECT * FROM v_aktyvus_nariai LIMIT 5;

\echo ''
\echo '--- Būsimos sesijos (pirmos 5) ---'
SELECT * FROM v_busimos_sesijos LIMIT 5;

\echo ''
\echo '--- Trenerių krūviai ---'
SELECT * FROM v_treneriu_kruviai;

\echo '================================================'