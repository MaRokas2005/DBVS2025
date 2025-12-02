-- ============================================
-- TRIGERIAI
-- Laboratorinis darbas (atliekamas poroje)
-- Autoriai: [Jūsų vardai]
-- Data: 2025-01-24
-- ============================================

SET search_path TO "$user";

-- ============================================
-- TRIGERIAI
-- Poroje reikia bent 2 trigerių
-- SVARBU: Tik tokiems reikalavimams, kurių 
-- NEGALIMA užtikrinti CHECK, FOREIGN KEY ar kitais būdais
-- ============================================

-- --------------------------------------------
-- TRIGERIS 1: Automatinis dalyvių skaičiaus atnaujinimas
-- --------------------------------------------
-- DALYKINĖ TAISYKLĖ: Kai narys užsiregistruoja arba atsisako 
-- treniruotės, automatiškai atnaujinti sesijos 
-- uzsiregistravusiu_dalyviu_skaicius lauką.
-- 
-- KODĖL REIKALINGAS TRIGERIS: 
-- Negalima užtikrinti CHECK constraint'u, nes reikia 
-- automatiškai skaičiuoti kitoje lentelėje.

-- Funkcija, kuri perskaičiuoja dalyvių skaičių
CREATE OR REPLACE FUNCTION atnaujinti_dalyviu_skaiciu()
RETURNS TRIGGER AS $$
BEGIN
    -- Atnaujinti sesijos dalyvių skaičių
    UPDATE SESIJA
    SET uzsiregistravusiu_dalyviu_skaicius = (
        SELECT COUNT(*)
        FROM DALYVAVIMAS
        WHERE treniruotesid = COALESCE(NEW.treniruotesid, OLD.treniruotesid)
          AND sesijos_nr = COALESCE(NEW.sesijos_nr, OLD.sesijos_nr)
          AND statusas IN ('Užsiregistravo', 'Dalyvavo')
    )
    WHERE treniruotesid = COALESCE(NEW.treniruotesid, OLD.treniruotesid)
      AND sesijos_nr = COALESCE(NEW.sesijos_nr, OLD.sesijos_nr);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigeris INSERT
CREATE TRIGGER trg_dalyvavimas_insert
AFTER INSERT ON DALYVAVIMAS
FOR EACH ROW
EXECUTE FUNCTION atnaujinti_dalyviu_skaiciu();

-- Trigeris UPDATE
CREATE TRIGGER trg_dalyvavimas_update
AFTER UPDATE ON DALYVAVIMAS
FOR EACH ROW
WHEN (OLD.statusas IS DISTINCT FROM NEW.statusas)
EXECUTE FUNCTION atnaujinti_dalyviu_skaiciu();

-- Trigeris DELETE
CREATE TRIGGER trg_dalyvavimas_delete
AFTER DELETE ON DALYVAVIMAS
FOR EACH ROW
EXECUTE FUNCTION atnaujinti_dalyviu_skaiciu();

COMMENT ON FUNCTION atnaujinti_dalyviu_skaiciu() IS 
'Automatiškai atnaujina sesijos dalyvių skaičių, kai keičiasi DALYVAVIMAS įrašai';

-- --------------------------------------------
-- TRIGERIS 2: Patikrinimas, ar salė neperildyta
-- --------------------------------------------
-- DALYKINĖ TAISYKLĖ: Negalima užsiregistruoti į treniruotę,
-- jei salės maksimali talpa būtų viršyta.
--
-- KODĖL REIKALINGAS TRIGERIS:
-- CHECK constraint'as negali patikrinti sąlygos, kuri 
-- priklauso nuo kitų lentelių duomenų (SALE.maksimali_talpa)

CREATE OR REPLACE FUNCTION tikrinti_sales_talpa()
RETURNS TRIGGER AS $$
DECLARE
    v_maksimali_talpa INTEGER;
    v_dabartinis_skaicius INTEGER;
    v_sales_pavadinimas VARCHAR(50);
BEGIN
    -- Gauti salės maksimalią talpą ir dabartinį skaičių
    SELECT 
        sa.maksimali_talpa,
        s.uzsiregistravusiu_dalyviu_skaicius + 1, -- +1 naujas registruojamas
        sa.pavadinimas
    INTO 
        v_maksimali_talpa,
        v_dabartinis_skaicius,
        v_sales_pavadinimas
    FROM SESIJA s
    JOIN SALE sa ON s.salesid = sa.salesid
    WHERE s.treniruotesid = NEW.treniruotesid
      AND s.sesijos_nr = NEW.sesijos_nr;
    
    -- Patikrinti, ar neviršijama talpa
    IF v_dabartinis_skaicius > v_maksimali_talpa THEN
        RAISE EXCEPTION 'Salė "%" pilna! Maksimali talpa: %, jau užsiregistravo: %', 
            v_sales_pavadinimas, 
            v_maksimali_talpa, 
            v_dabartinis_skaicius - 1;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tikrinti_sales_talpa
BEFORE INSERT ON DALYVAVIMAS
FOR EACH ROW
WHEN (NEW.statusas IN ('Užsiregistravo', 'Dalyvavo'))
EXECUTE FUNCTION tikrinti_sales_talpa();

COMMENT ON FUNCTION tikrinti_sales_talpa() IS 
'Užkerta kelią registracijai, jei salės talpa būtų viršyta';

-- --------------------------------------------
-- TRIGERIS 3: Neleisti trinti aktyvių abonementų su mokėjimais
-- --------------------------------------------
-- DALYKINĖ TAISYKLĖ: Negalima ištrinti aktyvaus abonamento,
-- jei yra bent vienas susietas mokėjimas.
--
-- KODĖL REIKALINGAS TRIGERIS:
-- ON DELETE CASCADE leistų ištrinti, bet mes norime užkirsti kelią

CREATE OR REPLACE FUNCTION uzkirst_abonementu_trynima()
RETURNS TRIGGER AS $$
DECLARE
    v_mokejimo_skaicius INTEGER;
BEGIN
    -- Patikrinti, ar yra mokėjimų
    SELECT COUNT(*) INTO v_mokejimo_skaicius
    FROM MOKEJIMAS
    WHERE abonementoid = OLD.abonementoid;
    
    -- Jei abonementas aktyvus ir turi mokėjimų, neleisti trinti
    IF OLD.statusas = 'Aktyvus' AND v_mokejimo_skaicius > 0 THEN
        RAISE EXCEPTION 'Negalima ištrinti aktyvaus abonamento ID %, nes jis turi % mokėjimų. Pirmiau pakeiskite statusą į "Pasibaigęs".', 
            OLD.abonementoid, 
            v_mokejimo_skaicius;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_uzkirst_abonementu_trynima
BEFORE DELETE ON ABONEMENTAS
FOR EACH ROW
EXECUTE FUNCTION uzkirst_abonementu_trynima();

COMMENT ON FUNCTION uzkirst_abonementu_trynima() IS 
'Apsaugo aktyvius abonementus su mokėjimais nuo atsitiktinio ištrynimo';

-- --------------------------------------------
-- TRIGERIS 4: Automatinis abonamento statuso keitimas
-- --------------------------------------------
-- DALYKINĖ TAISYKLĖ: Kai abonementas pasibaigia (pabaigos_data < CURRENT_DATE),
-- automatiškai pakeisti statusą į "Pasibaigęs"
--
-- KODĖL REIKALINGAS TRIGERIS:
-- Negalima su CHECK, nes reikia automatinio keitimo pagal datą

CREATE OR REPLACE FUNCTION atnaujinti_abonementu_statusus()
RETURNS TRIGGER AS $$
BEGIN
    -- Jei pabaigos data praėjo, pakeisti statusą
    IF NEW.pabaigos_data IS NOT NULL 
       AND NEW.pabaigos_data < CURRENT_DATE 
       AND NEW.statusas = 'Aktyvus' THEN
        NEW.statusas := 'Pasibaigęs';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_abonementas_statusas_insert
BEFORE INSERT ON ABONEMENTAS
FOR EACH ROW
EXECUTE FUNCTION atnaujinti_abonementu_statusus();

CREATE TRIGGER trg_abonementas_statusas_update
BEFORE UPDATE ON ABONEMENTAS
FOR EACH ROW
WHEN (OLD.pabaigos_data IS DISTINCT FROM NEW.pabaigos_data 
      OR OLD.statusas IS DISTINCT FROM NEW.statusas)
EXECUTE FUNCTION atnaujinti_abonementu_statusus();

COMMENT ON FUNCTION atnaujinti_abonementu_statusus() IS 
'Automatiškai keičia abonementų statusą į "Pasibaigęs", kai praeina pabaigos data';

-- ============================================
-- TRIGERIŲ IŠTRYNIMO SAKINIAI (dokumentacijai)
-- ============================================

\echo '================================================'
\echo 'Trigeriai ir funkcijos sukurti sėkmingai!'
\echo '================================================'

-- Parodyti visus trigerius
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing
FROM information_schema.triggers
WHERE trigger_schema = '$user'
ORDER BY event_object_table, trigger_name;