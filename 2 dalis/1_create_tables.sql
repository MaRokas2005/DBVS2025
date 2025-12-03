-- Nustatyti schemą (jūsų MIF vartotojo vardas)
SET search_path TO "$user";

CREATE TABLE NARYS (
    narioID SERIAL PRIMARY KEY, 

    vardas VARCHAR(50) NOT NULL,
    pavarde VARCHAR(50) NOT NULL,
    
    telefonas VARCHAR(20),
    
    el_pastas VARCHAR(100) UNIQUE,  
    
    gimimo_data DATE CHECK (gimimo_data <= CURRENT_DATE),  
    
    registracijos_data DATE DEFAULT CURRENT_DATE,  
    
    gatve VARCHAR(100),
    miestas VARCHAR(50) DEFAULT 'Vilnius',
    namo_nr VARCHAR(10),
    
    lytis VARCHAR(10) CHECK (lytis IN ('Vyras', 'Moteris', 'Kita')), 
    
    sveikatos_pastabos TEXT,
    
    CONSTRAINT amziaus_check CHECK (
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, gimimo_data)) >= 14
    ) 
);

CREATE TABLE TRENERIS (
    trenerioID SERIAL PRIMARY KEY, 
    
    vardas VARCHAR(50) NOT NULL,
    pavarde VARCHAR(50) NOT NULL,
    
    specializacija VARCHAR(100) NOT NULL,
    
    telefonas VARCHAR(20),
    el_pastas VARCHAR(100) UNIQUE, 
    
    darbo_pradzia DATE NOT NULL,
    
    CONSTRAINT darbo_data_check CHECK (darbo_pradzia >= '2020-01-01')  
);

CREATE TABLE SALE (
    salesID SERIAL PRIMARY KEY, 
    
    pavadinimas VARCHAR(50) NOT NULL UNIQUE, 
    
    plotas_kv_m DECIMAL(6,2) CHECK (plotas_kv_m > 0),
    
    maksimali_talpa INTEGER CHECK (maksimali_talpa > 0 AND maksimali_talpa <= 100), 
    
    sales_tipas TEXT DEFAULT 'Bendra' 
);

CREATE TABLE TRENIRUOTE (
    treniruotesID SERIAL PRIMARY KEY,
    
    pavadinimas VARCHAR(100) NOT NULL,
    
    tipas VARCHAR(20) CHECK (tipas IN ('Grupinė', 'Individuali', 'Hibridinė')),
    
    trukme_minutemis INTEGER CHECK (trukme_minutemis BETWEEN 15 AND 180),
    
    maksimalus_dalyviu_skaicius INTEGER DEFAULT 20,
    
    sudetingumo_lygis VARCHAR(20)
);

CREATE TABLE ABONEMENTAS (
    abonementoID SERIAL PRIMARY KEY, 
    
    narioID INTEGER NOT NULL REFERENCES NARYS(narioID) ON DELETE CASCADE,
    
    tipas VARCHAR(20) NOT NULL,
    
    kaina DECIMAL(8,2) NOT NULL CHECK (kaina >= 0), 
    
    pradzios_data DATE NOT NULL,
    pabaigos_data DATE,
    
    statusas VARCHAR(20) DEFAULT 'Aktyvus', 

    CONSTRAINT datos_check CHECK (pabaigos_data IS NULL OR pabaigos_data > pradzios_data) 
);

CREATE TABLE MOKEJIMAS (
    mokejimoID SERIAL PRIMARY KEY, 
    
    abonementoID INTEGER NOT NULL REFERENCES ABONEMENTAS(abonementoID) ON DELETE CASCADE,
    
    data DATE DEFAULT CURRENT_DATE,
    
    kaina INTEGER NOT NULL CHECK (kaina > 0), 
    
    budas VARCHAR(20) DEFAULT 'Kortelė',
    
    statusas VARCHAR(20) DEFAULT 'Apmokėta' 
);

CREATE TABLE SESIJA (
    treniruotesID INTEGER NOT NULL REFERENCES TRENIRUOTE(treniruotesID) ON DELETE CASCADE,
    sesijos_nr INTEGER NOT NULL,
    
    data DATE NOT NULL,
    pradzios_laikas TIME NOT NULL,
    pabaigos_laikas TIME NOT NULL,
    
    trenerioID INTEGER REFERENCES TRENERIS(trenerioID) ON DELETE SET NULL,
    salesID INTEGER REFERENCES SALE(salesID) ON DELETE SET NULL,
    
    uzsiregistravusiu_dalyviu_skaicius INTEGER DEFAULT 0,  
    
    statusas VARCHAR(20) DEFAULT 'Suplanuota',
    
    PRIMARY KEY (treniruotesID, sesijos_nr),
    
    CONSTRAINT laiko_check CHECK (pabaigos_laikas > pradzios_laikas)
);

CREATE TABLE DALYVAVIMAS (
    narioID INTEGER NOT NULL REFERENCES NARYS(narioID) ON DELETE CASCADE,
    treniruotesID INTEGER NOT NULL,
    sesijos_nr INTEGER NOT NULL,
    
    registracijos_data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    
    statusas VARCHAR(20) DEFAULT 'Užsiregistravo', 
    
    ivertinimas INTEGER CHECK (ivertinimas IS NULL OR (ivertinimas BETWEEN 1 AND 5)), 
    
    pastabos TEXT,
    
    PRIMARY KEY (narioID, treniruotesID, sesijos_nr),
    
    FOREIGN KEY (treniruotesID, sesijos_nr) 
        REFERENCES SESIJA(treniruotesID, sesijos_nr) ON DELETE CASCADE
);

CREATE TABLE TRENERIS_SESIJA (
    trenerioID INTEGER NOT NULL REFERENCES TRENERIS(trenerioID) ON DELETE CASCADE,
    treniruotesID INTEGER NOT NULL,
    sesijos_nr INTEGER NOT NULL,
    
    PRIMARY KEY (trenerioID, treniruotesID, sesijos_nr),
    
    FOREIGN KEY (treniruotesID, sesijos_nr) 
        REFERENCES SESIJA(treniruotesID, sesijos_nr) ON DELETE CASCADE
);