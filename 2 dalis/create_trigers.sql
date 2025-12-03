SET search_path TO "$user";

CREATE OR REPLACE FUNCTION atnaujinti_dalyviu_skaiciu()
RETURNS TRIGGER AS $$
BEGIN
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

CREATE TRIGGER trg_dalyvavimas_insert
AFTER INSERT ON DALYVAVIMAS
FOR EACH ROW
EXECUTE FUNCTION atnaujinti_dalyviu_skaiciu();

CREATE TRIGGER trg_dalyvavimas_update
AFTER UPDATE ON DALYVAVIMAS
FOR EACH ROW
WHEN (OLD.statusas IS DISTINCT FROM NEW.statusas)
EXECUTE FUNCTION atnaujinti_dalyviu_skaiciu();

CREATE TRIGGER trg_dalyvavimas_delete
AFTER DELETE ON DALYVAVIMAS
FOR EACH ROW
EXECUTE FUNCTION atnaujinti_dalyviu_skaiciu();

COMMENT ON FUNCTION atnaujinti_dalyviu_skaiciu() IS 
'Automatiškai atnaujina sesijos dalyvių skaičių, kai keičiasi DALYVAVIMAS įrašai';

CREATE OR REPLACE FUNCTION tikrinti_sales_talpa()
RETURNS TRIGGER AS $$
DECLARE
    v_maksimali_talpa INTEGER;
    v_dabartinis_skaicius INTEGER;
    v_sales_pavadinimas VARCHAR(50);
BEGIN
    SELECT 
        sa.maksimali_talpa,
        s.uzsiregistravusiu_dalyviu_skaicius + 1, 
        sa.pavadinimas
    INTO 
        v_maksimali_talpa,
        v_dabartinis_skaicius,
        v_sales_pavadinimas
    FROM SESIJA s
    JOIN SALE sa ON s.salesid = sa.salesid
    WHERE s.treniruotesid = NEW.treniruotesid
      AND s.sesijos_nr = NEW.sesijos_nr;
    
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

CREATE OR REPLACE FUNCTION uzkirst_abonementu_trynima()
RETURNS TRIGGER AS $$
DECLARE
    v_mokejimo_skaicius INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_mokejimo_skaicius
    FROM MOKEJIMAS
    WHERE abonementoid = OLD.abonementoid;
    
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

CREATE OR REPLACE FUNCTION atnaujinti_abonementu_statusus()
RETURNS TRIGGER AS $$
BEGIN
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

SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing
FROM information_schema.triggers
WHERE trigger_schema = '$user'
ORDER BY event_object_table, trigger_name;