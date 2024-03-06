CREATE OR REPLACE PROCEDURE add_to_species(l INT, sn VARCHAR, h VARCHAR, fn VARCHAR) 
    LANGUAGE plpgsql
AS $$
BEGIN
    IF l IS NULL OR sn IS NULL OR h IS NULL OR fn IS NULL
    THEN
        RAISE EXCEPTION 'Введено недопустимое значение NULL';
    END IF;
    -- Проверка на уникальность имени вида
    IF EXISTS (
        SELECT 1
        FROM species
        WHERE species_name = sn
    ) THEN
        RAISE EXCEPTION 'Имя вида уже существует: %', sn;
    END IF;
    
    INSERT INTO species (lifespan, species_name, habitat, family_name)
    VALUES (l, sn, h, fn)
    ON CONFLICT DO NOTHING;
END;
$$; 

CREATE OR REPLACE PROCEDURE add_to_enclosure(en INT, s INT, ena VARCHAR, ra BOOLEAN) 
    LANGUAGE plpgsql
AS $$
BEGIN
    IF en IS NULL OR s IS NULL OR ena IS NULL OR ra IS NULL
    THEN
        RAISE EXCEPTION 'Введено недопустимое значение NULL';
    END IF;

    -- Проверка на уникальность имени вида
    IF EXISTS (
        SELECT 1
        FROM enclosure
        WHERE enclosure_number = en
    ) THEN
        RAISE EXCEPTION 'Номер помемщения уже занят: %', en;
    END IF;
    
    INSERT INTO enclosure (enclosure_number, square, enclosure_name, reservoir_availability)
    VALUES (en, s, ena, ra)
    ON CONFLICT DO NOTHING;
END;
$$;


CREATE OR REPLACE PROCEDURE add_to_placement(noa INT, si INT, ei INT) 
    LANGUAGE plpgsql
AS $$
BEGIN
    IF noa IS NULL OR si IS NULL OR ei IS NULL
    THEN
        RAISE EXCEPTION 'Введено недопустимое значение NULL';
    END IF;

    -- Проверка на существование вида и помещения
    IF NOT EXISTS (
        SELECT 1
        FROM species
        WHERE species_id = si
    ) THEN
        RAISE EXCEPTION 'Не существует вида: %', si;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1
        FROM enclosure
        WHERE enclosure_id = ei
    ) THEN
        RAISE EXCEPTION 'Не существует помещения: %', ei;
    END IF;
    
    INSERT INTO placement (number_of_animals, species_id, enclosure_id)
    VALUES (noa, si, ei)
    ON CONFLICT DO NOTHING;
END;
$$;



CREATE OR REPLACE PROCEDURE update_placement_by_id(pid INT,noa INT, si INT, ei INT) 
    LANGUAGE plpgsql
AS $$
BEGIN
    IF noa IS NULL OR si IS NULL OR ei IS NULL or pid is NULL
    THEN
        RAISE EXCEPTION 'Введено недопустимое значение NULL';
    END IF;
    -- Проверка на существование вида и помещения
    IF NOT EXISTS (
        SELECT 1
        FROM species
        WHERE species_id = si
    ) THEN
        RAISE EXCEPTION 'Не существует вида: %', si;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1
        FROM enclosure
        WHERE enclosure_id = ei
    ) THEN
        RAISE EXCEPTION 'Не существует помещения: %', ei;
    END IF;
    
    UPDATE placement 
    SET number_of_animals = noa, species_id = si, enclosure_id = ei
    WHERE placement_id = pid;
END;
$$;



CREATE OR REPLACE PROCEDURE update_species_by_family_name(fn VARCHAR, h VARCHAR) 
    LANGUAGE plpgsql
AS $$
BEGIN
    IF fn IS NULL OR h IS NULL
    THEN
        RAISE EXCEPTION 'Введено недопустимое значение NULL';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1
        FROM species
        WHERE family_name = fn
    ) THEN
        RAISE EXCEPTION 'Не существует семейства: %', fn;
    END IF;

    UPDATE species 
    SET habitat = h
    WHERE family_name = fn;
END;
$$;



CREATE OR REPLACE PROCEDURE update_enclosure_reservoir_by_square(s INT, ra BOOLEAN) 
    LANGUAGE plpgsql
AS $$
BEGIN
    IF s IS NULL OR ra IS NULL
    THEN
        RAISE EXCEPTION 'Введено недопустимое значение NULL';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1
        FROM enclosure
        WHERE square > s
    ) THEN
        RAISE EXCEPTION 'Не существует площади больше чем: %', s;
    END IF;

    UPDATE enclosure 
    SET reservoir_availability = ra
    WHERE square > s;
END;
$$;


CREATE OR REPLACE PROCEDURE delete_enclosure_by_enclosure_number(en INT) 
    LANGUAGE plpgsql
AS $$
BEGIN
    IF en IS NULL
    THEN
        RAISE EXCEPTION 'Введено недопустимое значение NULL';
    END IF;

    -- Проверка на удаляем помещение, в котором живут животные или работает сотрудник.
    IF EXISTS (
        SELECT 1
        FROM enclosure e, animal an
        WHERE enclosure_number = en and e.enclosure_id = an.enclosure_id
    ) THEN
        RAISE EXCEPTION 'В помещении живут животные: %', en;
    END IF;
    
    IF EXISTS (
        SELECT 1
        FROM enclosure e, employee em
        WHERE enclosure_number = en and e.enclosure_id = em.enclosure_id
    ) THEN
        RAISE EXCEPTION 'В помещении работают сотрудники: %', en;
    END IF;
    
    DELETE FROM enclosure WHERE enclosure_number = en;
END;
$$;



CREATE OR REPLACE PROCEDURE delete_species_by_name(sn VARCHAR) 
    LANGUAGE plpgsql
AS $$
BEGIN
    IF sn IS NULL
    THEN
        RAISE EXCEPTION 'Введено недопустимое значение NULL';
    END IF;

    -- Проверка на задействованы в таблице Размещение или Животное
    IF EXISTS (
        SELECT 1
        FROM species s, animal an
        WHERE species_name = sn and s.species_id = an.species_id
    ) THEN
        RAISE EXCEPTION 'Существуют животные этого вида: %', sn;
    END IF;
    
    IF EXISTS (
        SELECT 1
        FROM species s, placement pl
        WHERE species_name = sn and s.species_id = pl.species_id
    ) THEN
        RAISE EXCEPTION 'Существуют размещения с заданным видом: %', sn;
    END IF;
    
    DELETE FROM species WHERE species_name = sn;
END;
$$;


CREATE OR REPLACE PROCEDURE delete_placement_by_id(pi INT) 
    LANGUAGE plpgsql
AS $$
BEGIN
    IF pi IS NULL
    THEN
        RAISE EXCEPTION 'Введено недопустимое значение NULL';
    END IF;
    
    DELETE FROM placement WHERE placement_id = pi;
END;
$$;





