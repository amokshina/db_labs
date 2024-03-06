CREATE OR REPLACE FUNCTION check_water_animal() 
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.species_id IN (SELECT species_id 
                          FROM species 
                          WHERE habitat IN ('ocean', 'freshwater')) 
       AND NEW.enclosure_id NOT IN (SELECT enclosure_id 
                                    FROM enclosure 
                                    WHERE reservoir_availability = true) THEN
        RAISE EXCEPTION 'Нельзя поселить животное, обитающее в водной среде, в вольер без водоема';
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER water_animal_trigger
BEFORE INSERT OR UPDATE 
ON placement
FOR EACH ROW
EXECUTE FUNCTION check_water_animal();


CREATE OR REPLACE FUNCTION check_double_animal() 
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM animal 
        WHERE 
            animal_name = NEW.animal_name 
            AND birth_date = NEW.birth_date 
            AND species_id = NEW.species_id 
            AND enclosure_id = NEW.enclosure_id
    ) THEN
        RAISE EXCEPTION 'Дублирование животного';
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER double_animal_trigger
BEFORE INSERT OR UPDATE 
ON animal
FOR EACH ROW
EXECUTE FUNCTION check_double_animal();


CREATE OR REPLACE FUNCTION check_double_employee() 
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM employee 
        WHERE 
            employee_name = NEW.employee_name 
            AND employee_role = NEW.employee_role 
            AND enclosure_id = NEW.enclosure_id) THEN
        RAISE EXCEPTION 'Дублирование сотрудника';
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER double_employee_trigger
BEFORE INSERT OR UPDATE 
ON employee
FOR EACH ROW
EXECUTE FUNCTION check_double_employee();


CREATE OR REPLACE FUNCTION check_double_species() 
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM species 
        WHERE 
            lifespan = NEW.lifespan 
            AND species_name = NEW.species_name 
            AND habitat = NEW.habitat
            AND family_name = NEW.family_name) THEN
        RAISE EXCEPTION 'Дублирование вида животного';
        RETURN NULL;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER double_species_trigger
BEFORE INSERT OR UPDATE of range
ON species
FOR EACH ROW
EXECUTE FUNCTION check_double_species();



CREATE OR REPLACE FUNCTION check_delete_enclosure() 
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM animal
        WHERE enclosure_id = OLD.enclosure_id
    ) THEN
        RAISE EXCEPTION 'Нельзя удалить помещение, в котором живет животное';
        RETURN NULL;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM employee
        WHERE enclosure_id = OLD.enclosure_id
    ) THEN
        RAISE EXCEPTION 'Нельзя удалить помещение, в котором работает сотрудник';
        RETURN NULL;
    END IF;
    
    RETURN OLD;
END;
$$;

CREATE OR REPLACE TRIGGER delete_enclosure_trigger
BEFORE DELETE 
ON enclosure
FOR EACH ROW
EXECUTE FUNCTION check_delete_enclosure();



CREATE TABLE animal_employee_counts (
    animal_count INTEGER DEFAULT 0,
    employee_count INTEGER DEFAULT 0
);

INSERT INTO animal_employee_counts DEFAULT VALUES;

UPDATE animal_employee_counts
SET 
    animal_count = (SELECT COUNT(*) FROM animal),
    employee_count = (SELECT COUNT(*) FROM employee);



CREATE OR REPLACE FUNCTION update_counts_animals() 
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN 
        UPDATE animal_employee_counts
        SET animal_count = animal_count + 1;
        RETURN NEW;
    END IF;
    
    
    IF TG_OP = 'DELETE' THEN 
        UPDATE animal_employee_counts
        SET animal_count = animal_count - 1;
        RETURN NULL;
    END IF;

END;
$$;
CREATE OR REPLACE TRIGGER animal_count_trigger
AFTER INSERT OR DELETE
ON animal
FOR EACH ROW
EXECUTE FUNCTION update_counts_animals();

CREATE OR REPLACE FUNCTION update_counts_employee() 
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN 
        UPDATE animal_employee_counts
        SET employee_count = employee_count + 1;
        RETURN NEW;
    END IF;
    
    
    IF TG_OP = 'DELETE' THEN 
        UPDATE animal_employee_counts
        SET employee_count = employee_count - 1;
        RETURN NULL;
    END IF;

END;
$$;

CREATE OR REPLACE TRIGGER employee_count_trigger
AFTER INSERT OR DELETE
ON employee
FOR EACH ROW
EXECUTE FUNCTION update_counts_employee() ;



