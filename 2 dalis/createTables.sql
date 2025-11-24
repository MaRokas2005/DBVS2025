
-- Nustatyti schemą (jūsų MIF vartotojo vardas)
SET search_path TO pice1138, public;
-- ============================================
-- LENTELIŲ IŠTRYNIMAS (jei egzistuoja)
-- ============================================

DROP TABLE IF EXISTS TRENERIS_SESIJA CASCADE;
DROP TABLE IF EXISTS DALYVAVIMAS CASCADE;
DROP TABLE IF EXISTS SESIJA CASCADE;
DROP TABLE IF EXISTS MOKEJIMAS CASCADE;
DROP TABLE IF EXISTS ABONEMENTAS CASCADE;
DROP TABLE IF EXISTS TRENIRUOTE CASCADE;
DROP TABLE IF EXISTS SALE CASCADE;
DROP TABLE IF EXISTS TRENERIS CASCADE;
DROP TABLE IF EXISTS NARYS CASCADE;

-- ============================================
-- LENTELIŲ KŪRIMAS
-- ============================================

-- --------------------------------------------
-- 1. NARYS
-- --------------------------------------------
CREATE TABLE NARYS (
    narioID SERIAL PRIMARY KEY,  -- Automatinis tapatumo požymis (1)
    
    -- SUDĖTINIS ATRIBUTAS: Pilnas_vardas
    vardas VARCHAR(50) NOT NULL,
    pavarde VARCHAR(50) NOT NULL,
    
    -- Paprastas atributas
    telefonas VARCHAR(20),
    
    el_pastas VARCHAR(100) UNIQUE,  -- UNIQUE constraint
    
    gimimo_data DATE CHECK (gimimo_data <= CURRENT_DATE),  -- CHECK (1)
    
    registracijos_data DATE DEFAULT CURRENT_DATE,  -- DEFAULT (1)
    
    -- SUDĖTINIS ATRIBUTAS: Adresas
    gatve VARCHAR(100),
    miestas VARCHAR(50) DEFAULT 'Vilnius',  -- DEFAULT (2)
    namo_nr VARCHAR(10),
    
    lytis VARCHAR(10) CHECK (lytis IN ('Vyras', 'Moteris', 'Kita')),  -- CHECK (2)
    
    sveikatos_pastabos TEXT,
    
    -- Dalykinė taisyklė: narys turi būti bent 14 metų
    CONSTRAINT amziaus_check CHECK (
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, gimimo_data)) >= 14
    )  -- CHECK (3)
);

-- --------------------------------------------
-- 2. TRENERIS
-- --------------------------------------------
CREATE TABLE TRENERIS (
    trenerioID SERIAL PRIMARY KEY,  -- Automatinis tapatumo požymis (2)
    
    vardas VARCHAR(50) NOT NULL,
    pavarde VARCHAR(50) NOT NULL,
    
    specializacija VARCHAR(100) NOT NULL,
    
    telefonas VARCHAR(20),
    el_pastas VARCHAR(100) UNIQUE,  -- UNIQUE constraint
    
    darbo_pradzia DATE NOT NULL,
    
    -- Treneris dirba nuo 2020 metų arba vėliau
    CONSTRAINT darbo_data_check CHECK (darbo_pradzia >= '2020-01-01')  -- CHECK (4)
);

-- --------------------------------------------
-- 3. SALE
-- --------------------------------------------
CREATE TABLE SALE (
    salesID SERIAL PRIMARY KEY,  -- Automatinis tapatumo požymis (3)
    
    pavadinimas VARCHAR(50) NOT NULL UNIQUE,  -- UNIQUE constraint
    
    plotas_kv_m DECIMAL(6,2) CHECK (plotas_kv_m > 0),  -- CHECK (5)
    
    maksimali_talpa INTEGER CHECK (maksimali_talpa > 0 AND maksimali_talpa <= 100),  -- CHECK (6)
    
    sales_tipas TEXT DEFAULT 'Bendra'  -- DEFAULT (3)
);

-- --------------------------------------------
-- 4. TRENIRUOTE
-- --------------------------------------------
CREATE TABLE TRENIRUOTE (
    treniruotesID SERIAL PRIMARY KEY,  -- Automatinis tapatumo požymis (4)
    
    pavadinimas VARCHAR(100) NOT NULL,
    
    tipas VARCHAR(20) CHECK (tipas IN ('Grupinė', 'Individuali', 'Hibridinė')),  -- CHECK (7)
    
    trukme_minutemis INTEGER CHECK (trukme_minutemis BETWEEN 15 AND 180),  -- CHECK (8)
    
    maksimalus_dalyviu_skaicius INTEGER DEFAULT 20,  -- DEFAULT (4)
    
    sudetingumo_lygis VARCHAR(20)
);

-- --------------------------------------------
-- 5. ABONEMENTAS
-- --------------------------------------------
CREATE TABLE ABONEMENTAS (
    abonementoID SERIAL PRIMARY KEY,  -- Automatinis tapatumo požymis (5)
    
    narioID INTEGER NOT NULL REFERENCES NARYS(narioID) ON DELETE CASCADE,
    
    tipas VARCHAR(20) NOT NULL,
    
    kaina DECIMAL(8,2) NOT NULL CHECK (kaina >= 0),  -- CHECK (9)
    
    pradzios_data DATE NOT NULL,
    pabaigos_data DATE,
    
    statusas VARCHAR(20) DEFAULT 'Aktyvus',  -- DEFAULT (5)
    
    -- Abonementas baigiasi po pradžios
    CONSTRAINT datos_check CHECK (pabaigos_data IS NULL OR pabaigos_data > pradzios_data)  -- CHECK (10)
);

-- --------------------------------------------
-- 6. MOKEJIMAS
-- --------------------------------------------
CREATE TABLE MOKEJIMAS (
    mokejimoID SERIAL PRIMARY KEY,  -- Automatinis tapatumo požymis (6)
    
    abonementoID INTEGER NOT NULL REFERENCES ABONEMENTAS(abonementoID) ON DELETE CASCADE,
    
    data DATE DEFAULT CURRENT_DATE,  -- DEFAULT (6)
    
    kaina INTEGER NOT NULL CHECK (kaina > 0),  -- CHECK (11)
    
    budas VARCHAR(20) DEFAULT 'Kortelė',  -- DEFAULT (7)
    
    statusas VARCHAR(20) DEFAULT 'Apmokėta'  -- DEFAULT (8)
);

-- --------------------------------------------
-- 7. SESIJA
-- --------------------------------------------
CREATE TABLE SESIJA (
    treniruotesID INTEGER NOT NULL REFERENCES TRENIRUOTE(treniruotesID) ON DELETE CASCADE,
    sesijos_nr INTEGER NOT NULL,
    
    data DATE NOT NULL,
    pradzios_laikas TIME NOT NULL,
    pabaigos_laikas TIME NOT NULL,
    
    trenerioID INTEGER REFERENCES TRENERIS(trenerioID) ON DELETE SET NULL,
    salesID INTEGER REFERENCES SALE(salesID) ON DELETE SET NULL,
    
    uzsiregistravusiu_dalyviu_skaicius INTEGER DEFAULT 0,  -- DEFAULT (9)
    
    statusas VARCHAR(20) DEFAULT 'Suplanuota',  -- DEFAULT (10)
    
    PRIMARY KEY (treniruotesID, sesijos_nr),
    
    -- Sesija baigiasi po pradžios
    CONSTRAINT laiko_check CHECK (pabaigos_laikas > pradzios_laikas)  -- CHECK (12)
);

-- --------------------------------------------
-- 8. DALYVAVIMAS
-- --------------------------------------------
CREATE TABLE DALYVAVIMAS (
    narioID INTEGER NOT NULL REFERENCES NARYS(narioID) ON DELETE CASCADE,
    treniruotesID INTEGER NOT NULL,
    sesijos_nr INTEGER NOT NULL,
    
    registracijos_data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- DEFAULT (11)
    
    statusas VARCHAR(20) DEFAULT 'Užsiregistravo',  -- DEFAULT (12)
    
    ivertinimas INTEGER CHECK (ivertinimas IS NULL OR (ivertinimas BETWEEN 1 AND 5)),  -- CHECK (13)
    
    pastabos TEXT,
    
    PRIMARY KEY (narioID, treniruotesID, sesijos_nr),
    
    FOREIGN KEY (treniruotesID, sesijos_nr) 
        REFERENCES SESIJA(treniruotesID, sesijos_nr) ON DELETE CASCADE
);

-- --------------------------------------------
-- 9. TRENERIS_SESIJA (N:M ryšys)
-- --------------------------------------------
CREATE TABLE TRENERIS_SESIJA (
    trenerioID INTEGER NOT NULL REFERENCES TRENERIS(trenerioID) ON DELETE CASCADE,
    treniruotesID INTEGER NOT NULL,
    sesijos_nr INTEGER NOT NULL,
    
    PRIMARY KEY (trenerioID, treniruotesID, sesijos_nr),
    
    FOREIGN KEY (treniruotesID, sesijos_nr) 
        REFERENCES SESIJA(treniruotesID, sesijos_nr) ON DELETE CASCADE
);

