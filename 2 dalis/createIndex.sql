SET search_path TO "$user";

-- ============================================
-- INDEKSŲ KŪRIMAS
-- Poroje reikia bent 4 indeksų:
-- - Bent 2 unique
-- - Bent 2 ne-unique
-- ============================================

-- --------------------------------------------
-- 1. UNIQUE indeksas narių el. paštui
-- --------------------------------------------
-- Pastaba: UNIQUE constraint jau sukūrė automatinį indeksą,
-- bet mes sukursime papildomą unique indeksą kitam stulpeliui

CREATE UNIQUE INDEX idx_treneris_el_pastas 
ON TRENERIS(el_pastas);

COMMENT ON INDEX idx_treneris_el_pastas IS 
'Unikalus indeksas trenerių el. paštams - pagreitina paiešką ir užtikrina unikalumą';

-- --------------------------------------------
-- 2. UNIQUE indeksas salių pavadinimams
-- --------------------------------------------
CREATE UNIQUE INDEX idx_sale_pavadinimas 
ON SALE(pavadinimas);

COMMENT ON INDEX idx_sale_pavadinimas IS 
'Unikalus indeksas salių pavadinimams';

-- --------------------------------------------
-- 3. Ne-unique indeksas narių pavardėms
-- --------------------------------------------
-- Paieška pagal pavardę - dažna operacija
CREATE INDEX idx_narys_pavarde 
ON NARYS(pavarde);

COMMENT ON INDEX idx_narys_pavarde IS 
'Indeksas pagreitina paiešką pagal nario pavardę (dažnai naudojama registracijoje)';

-- --------------------------------------------
-- 4. Ne-unique indeksas sesijų datoms
-- --------------------------------------------
-- Dažnai ieškome sesijų pagal datą
CREATE INDEX idx_sesija_data 
ON SESIJA(data);

COMMENT ON INDEX idx_sesija_data IS 
'Indeksas pagreitina sesijų paiešką pagal datą (pvz., šios savaitės treniruotės)';

-- --------------------------------------------
-- 5. Ne-unique composite indeksas
-- --------------------------------------------
-- Sudėtinis indeksas sesijos statusui ir datai
CREATE INDEX idx_sesija_statusas_data 
ON SESIJA(statusas, data);

COMMENT ON INDEX idx_sesija_statusas_data IS 
'Sudėtinis indeksas pagreitina paiešką pagal statusą ir datą (pvz., suplanuotos būsimos sesijos)';

-- --------------------------------------------
-- 6. Ne-unique indeksas abonementų statusui
-- --------------------------------------------
CREATE INDEX idx_abonementas_statusas 
ON ABONEMENTAS(statusas);

COMMENT ON INDEX idx_abonementas_statusas IS 
'Indeksas pagreitina aktyvių/pasibaigusių abonementų paiešką';

-- --------------------------------------------
-- 7. Ne-unique indeksas dalyvavimo registracijos datai
-- --------------------------------------------
CREATE INDEX idx_dalyvavimas_reg_data 
ON DALYVAVIMAS(registracijos_data);

COMMENT ON INDEX idx_dalyvavimas_reg_data IS 
'Indeksas pagreitina naujausių registracijų paiešką';

-- --------------------------------------------
-- 8. Unique composite indeksas
-- --------------------------------------------
-- Unikalus sudėtinis indeksas trenerio ir sesijos kombinacijai
-- (Nors TRENERIS_SESIJA jau turi PRIMARY KEY, parodysime, kaip veiktų)
CREATE UNIQUE INDEX idx_unique_treneris_specializacija 
ON TRENERIS(specializacija, pavarde);

COMMENT ON INDEX idx_unique_treneris_specializacija IS 
'Užtikrina, kad nėra dviejų trenerių su ta pačia specializacija ir pavarde';

-- ============================================
-- INDEKSŲ PERŽIŪRA
-- ============================================

-- Parodyti visus indeksus
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = '$user'
ORDER BY tablename, indexname;

