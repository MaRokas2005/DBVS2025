SET search_path TO "$user";

CREATE UNIQUE INDEX idx_treneris_el_pastas 
ON TRENERIS(el_pastas);

COMMENT ON INDEX idx_treneris_el_pastas IS 
'Unikalus indeksas trenerių el. paštams - pagreitina paiešką ir užtikrina unikalumą';

CREATE UNIQUE INDEX idx_sale_pavadinimas 
ON SALE(pavadinimas);

COMMENT ON INDEX idx_sale_pavadinimas IS 
'Unikalus indeksas salių pavadinimams';

CREATE INDEX idx_narys_pavarde 
ON NARYS(pavarde);

COMMENT ON INDEX idx_narys_pavarde IS 
'Indeksas pagreitina paiešką pagal nario pavardę (dažnai naudojama registracijoje)';

CREATE INDEX idx_sesija_data 
ON SESIJA(data);

COMMENT ON INDEX idx_sesija_data IS 
'Indeksas pagreitina sesijų paiešką pagal datą (pvz., šios savaitės treniruotės)';

CREATE INDEX idx_sesija_statusas_data 
ON SESIJA(statusas, data);

COMMENT ON INDEX idx_sesija_statusas_data IS 
'Sudėtinis indeksas pagreitina paiešką pagal statusą ir datą (pvz., suplanuotos būsimos sesijos)';

CREATE INDEX idx_abonementas_statusas 
ON ABONEMENTAS(statusas);

COMMENT ON INDEX idx_abonementas_statusas IS 
'Indeksas pagreitina aktyvių/pasibaigusių abonementų paiešką';

CREATE INDEX idx_dalyvavimas_reg_data 
ON DALYVAVIMAS(registracijos_data);

COMMENT ON INDEX idx_dalyvavimas_reg_data IS 
'Indeksas pagreitina naujausių registracijų paiešką';

CREATE UNIQUE INDEX idx_unique_treneris_specializacija 
ON TRENERIS(specializacija, pavarde);

COMMENT ON INDEX idx_unique_treneris_specializacija IS 
'Užtikrina, kad nėra dviejų trenerių su ta pačia specializacija ir pavarde';

SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = '$user'
ORDER BY tablename, indexname;