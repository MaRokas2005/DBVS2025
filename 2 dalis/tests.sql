SET search_path TO pice1138;

-- ============================================
-- 1. NARIAI
-- ============================================

INSERT INTO NARYS (vardas, pavarde, telefonas, el_pastas, gimimo_data, gatve, miestas, namo_nr, lytis, sveikatos_pastabos) VALUES
('Jonas', 'Jonaitis', '+37060012345', 'jonas.jonaitis@email.lt', '1995-05-15', 'Gedimino pr.', 'Vilnius', '10-15', 'Vyras', NULL),
('Petras', 'Petraitis', '+37061234567', 'petras.p@email.lt', '1990-08-20', 'Laisvės al.', 'Kaunas', '5A', 'Vyras', 'Kelio trauma 2023 m.'),
('Ona', 'Onaitė', '+37062345678', 'ona.onaite@email.lt', '1998-03-10', 'Savanorių pr.', 'Vilnius', '88', 'Moteris', NULL),
('Greta', 'Grėtaitė', '+37063456789', 'greta@email.lt', '2000-11-25', 'Tilto g.', 'Vilnius', '7-12', 'Moteris', NULL),
('Mindaugas', 'Mindauskas', '+37064567890', 'mindaugas.m@email.lt', '1985-01-30', 'Kauno g.', 'Vilnius', '45', 'Vyras', 'Astma'),
('Laura', 'Lauraitė', '+37065678901', 'laura.l@email.lt', '2002-07-18', 'Vytauto g.', 'Kaunas', '12B', 'Moteris', NULL),
('Tomas', 'Tomaitis', '+37066789012', 'tomas.t@email.lt', '1992-12-05', 'Žalgirio g.', 'Vilnius', '33', 'Vyras', NULL),
('Ieva', 'Ievaitė', '+37067890123', 'ieva.i@email.lt', '1997-09-22', 'Neries g.', 'Vilnius', '9-5', 'Moteris', NULL),
('Darius', 'Dariauskas', '+37068901234', 'darius@email.lt', '1988-04-14', 'Ukmergės g.', 'Vilnius', '100', 'Vyras', NULL),
('Rūta', 'Rūtaitė', '+37069012345', 'ruta.r@email.lt', '2001-06-30', 'Kalvarijų g.', 'Vilnius', '55-8', 'Moteris', NULL);

-- ============================================
-- 2. TRENERIAI
-- ============================================

INSERT INTO TRENERIS (vardas, pavarde, specializacija, telefonas, el_pastas, darbo_pradzia) VALUES
('Mantas', 'Treneris', 'Jėgos treniruotės', '+37061111111', 'mantas.t@sportosale.lt', '2022-01-15'),
('Greta', 'Trenerė', 'Yoga', '+37062222222', 'greta.t@sportosale.lt', '2021-06-01'),
('Lukas', 'Lukauskas', 'CrossFit', '+37063333333', 'lukas.l@sportosale.lt', '2020-09-10'),
('Ieva', 'Trenerytė', 'Pilates', '+37064444444', 'ieva.tr@sportosale.lt', '2023-03-20'),
('Tomas', 'Atletauskas', 'Kardio treniruotės', '+37065555555', 'tomas.a@sportosale.lt', '2022-11-05');

-- ============================================
-- 3. SALĖS
-- ============================================

INSERT INTO SALE (pavadinimas, plotas_kv_m, maksimali_talpa, sales_tipas) VALUES
('Pagrindinė salė', 150.00, 30, 'Bendra'),
('Yoga studija', 80.50, 15, 'Yoga'),
('CrossFit zona', 120.00, 20, 'CrossFit'),
('Pilates salė', 70.00, 12, 'Pilates'),
('Kardio zona', 100.00, 25, 'Kardio');

-- ============================================
-- 4. TRENIRUOTĖS
-- ============================================

INSERT INTO TRENIRUOTE (pavadinimas, tipas, trukme_minutemis, maksimalus_dalyviu_skaicius, sudetingumo_lygis) VALUES
('Jėgos treniruotė pradedantiesiems', 'Grupinė', 60, 15, 'Pradedantis'),
('Yoga ryto sesija', 'Grupinė', 90, 12, 'Vidutinis'),
('CrossFit WOD', 'Grupinė', 60, 18, 'Pažengęs'),
('Pilates core', 'Grupinė', 45, 10, 'Pradedantis'),
('HIIT kardio', 'Grupinė', 45, 20, 'Vidutinis'),
('Asmeninė treniruotė', 'Individuali', 60, 1, 'Visi lygiai'),
('Funkcinis treniravimas', 'Grupinė', 60, 15, 'Vidutinis'),
('Stretching', 'Grupinė', 30, 20, 'Pradedantis');

-- ============================================
-- 5. ABONEMENTAI
-- ============================================

INSERT INTO ABONEMENTAS (narioID, tipas, kaina, pradzios_data, pabaigos_data, statusas) VALUES
(1, 'Mėnesinis', 45.00, '2025-01-01', '2025-01-31', 'Aktyvus'),
(2, 'Trimėnesinis', 120.00, '2024-12-01', '2025-02-28', 'Aktyvus'),
(3, 'Metinis', 400.00, '2024-11-01', '2025-10-31', 'Aktyvus'),
(4, 'Mėnesinis', 45.00, '2025-01-15', '2025-02-14', 'Aktyvus'),
(5, 'Trimėnesinis', 120.00, '2025-01-01', '2025-03-31', 'Aktyvus'),
(6, 'Mėnesinis', 45.00, '2024-12-01', '2024-12-31', 'Pasibaigęs'),
(7, 'Metinis', 400.00, '2024-06-01', '2025-05-31', 'Aktyvus'),
(8, 'Trimėnesinis', 120.00, '2025-01-10', '2025-04-09', 'Aktyvus'),
(9, 'Mėnesinis', 45.00, '2025-01-20', '2025-02-19', 'Aktyvus'),
(10, 'Trimėnesinis', 120.00, '2024-11-15', '2025-02-14', 'Aktyvus');

-- ============================================
-- 6. MOKĖJIMAI
-- ============================================

INSERT INTO MOKEJIMAS (abonementoID, data, kaina, budas, statusas) VALUES
(1, '2025-01-01', 45, 'Kortelė', 'Apmokėta'),
(2, '2024-12-01', 120, 'Banko pavedimu', 'Apmokėta'),
(3, '2024-11-01', 400, 'Kortelė', 'Apmokėta'),
(4, '2025-01-15', 45, 'Grynais', 'Apmokėta'),
(5, '2025-01-01', 120, 'Kortelė', 'Apmokėta'),
(6, '2024-12-01', 45, 'Kortelė', 'Apmokėta'),
(7, '2024-06-01', 400, 'Banko pavedimu', 'Apmokėta'),
(8, '2025-01-10', 120, 'Kortelė', 'Apmokėta'),
(9, '2025-01-20', 45, 'Grynais', 'Apmokėta'),
(10, '2024-11-15', 120, 'Kortelė', 'Apmokėta');

-- ============================================
-- 7. SESIJOS
-- ============================================

INSERT INTO SESIJA (treniruotesID, sesijos_nr, data, pradzios_laikas, pabaigos_laikas, trenerioID, salesID, uzsiregistravusiu_dalyviu_skaicius, statusas) VALUES
-- Būsimos sesijos
(1, 1, '2025-01-27', '09:00', '10:00', 1, 1, 8, 'Suplanuota'),
(1, 2, '2025-01-29', '09:00', '10:00', 1, 1, 5, 'Suplanuota'),
(1, 3, '2025-01-31', '09:00', '10:00', 1, 1, 0, 'Suplanuota'),
(2, 1, '2025-01-27', '07:00', '08:30', 2, 2, 10, 'Suplanuota'),
(2, 2, '2025-01-29', '07:00', '08:30', 2, 2, 8, 'Suplanuota'),
(3, 1, '2025-01-27', '18:00', '19:00', 3, 3, 12, 'Suplanuota'),
(3, 2, '2025-01-28', '18:00', '19:00', 3, 3, 15, 'Suplanuota'),
(4, 1, '2025-01-28', '10:00', '10:45', 4, 4, 7, 'Suplanuota'),
(4, 2, '2025-01-30', '10:00', '10:45', 4, 4, 5, 'Suplanuota'),
(5, 1, '2025-01-27', '17:00', '17:45', 5, 5, 18, 'Suplanuota'),
(5, 2, '2025-01-29', '17:00', '17:45', 5, 5, 14, 'Suplanuota'),

-- Praeities sesijos (įvertinimams testuoti)
(1, 100, '2025-01-20', '09:00', '10:00', 1, 1, 12, 'Įvyko'),
(2, 100, '2025-01-22', '07:00', '08:30', 2, 2, 9, 'Įvyko');

-- ============================================
-- 8. DALYVAVIMAS
-- ============================================

INSERT INTO DALYVAVIMAS (narioID, treniruotesID, sesijos_nr, registracijos_data, statusas, ivertinimas, pastabos) VALUES
-- Būsimos treniruotės (be įvertinimų)
(1, 1, 1, '2025-01-20 10:00:00', 'Užsiregistravo', NULL, NULL),
(2, 1, 1, '2025-01-20 11:30:00', 'Užsiregistravo', NULL, NULL),
(3, 1, 1, '2025-01-21 09:15:00', 'Užsiregistravo', NULL, NULL),
(4, 1, 1, '2025-01-21 14:20:00', 'Užsiregistravo', NULL, NULL),
(5, 1, 1, '2025-01-22 08:45:00', 'Užsiregistravo', NULL, NULL),
(6, 1, 1, '2025-01-22 16:00:00', 'Užsiregistravo', NULL, NULL),
(7, 1, 1, '2025-01-23 12:00:00', 'Užsiregistravo', NULL, NULL),
(8, 1, 1, '2025-01-23 18:30:00', 'Užsiregistravo', NULL, NULL),

-- Yoga sesijos
(3, 2, 1, '2025-01-19 20:00:00', 'Užsiregistravo', NULL, NULL),
(4, 2, 1, '2025-01-20 08:00:00', 'Užsiregistravo', NULL, NULL),
(6, 2, 1, '2025-01-20 10:00:00', 'Užsiregistravo', NULL, NULL),
(8, 2, 1, '2025-01-21 07:30:00', 'Užsiregistravo', NULL, NULL),
(10, 2, 1, '2025-01-21 12:00:00', 'Užsiregistravo', NULL, NULL),

-- Praeities sesijos su įvertinimais
(1, 1, 100, '2025-01-15 10:00:00', 'Dalyvavo', 5, 'Puiki treniruotė!'),
(2, 1, 100, '2025-01-15 10:30:00', 'Dalyvavo', 4, 'Geras tempas'),
(3, 1, 100, '2025-01-16 09:00:00', 'Dalyvavo', 5, NULL),
(4, 1, 100, '2025-01-16 14:00:00', 'Nedalyvavo', NULL, 'Susirgau'),
(5, 1, 100, '2025-01-17 08:00:00', 'Dalyvavo', 5, 'Labai patiko!'),

(3, 2, 100, '2025-01-18 20:00:00', 'Dalyvavo', 5, 'Ramus ir efektyvus'),
(6, 2, 100, '2025-01-19 08:00:00', 'Dalyvavo', 4, NULL),
(8, 2, 100, '2025-01-19 10:00:00', 'Dalyvavo', 5, 'Geriausia trenerė!'),
(10, 2, 100, '2025-01-20 07:00:00', 'Dalyvavo', 3, 'Per sunku man');

-- ============================================
-- 9. TRENERIS_SESIJA (N:M ryšys)
-- ============================================

INSERT INTO TRENERIS_SESIJA (trenerioID, treniruotesID, sesijos_nr) VALUES
(1, 1, 1),
(1, 1, 2),
(1, 1, 3),
(1, 1, 100),
(2, 2, 1),
(2, 2, 2),
(2, 2, 100),
(3, 3, 1),
(3, 3, 2),
(4, 4, 1),
(4, 4, 2),
(5, 5, 1),
(5, 5, 2),

-- Papildomi treneriai kai kuriose sesijose
(1, 3, 1),  -- Mantas padeda Luke CrossFit
(4, 2, 1);  -- Ieva padeda Gretai Yoga
