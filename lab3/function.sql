CREATE OR REPLACE FUNCTION get_animal_by_name(an VARCHAR)
    RETURNS SETOF animal
    STABLE LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM animal a
    WHERE a.animal_name = an;
END;
$$;


CREATE OR REPLACE FUNCTION get_animal_by_id(ai INT)
    RETURNS SETOF animal
    STABLE LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM animal a
    WHERE a.animal_id = ai;
END;
$$;


CREATE OR REPLACE FUNCTION get_animal_by_enclosure(encl INT)-- enclosure number вводим
    RETURNS SETOF animal
    STABLE LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT  a.*
    FROM animal a
    JOIN enclosure e ON e.enclosure_id = a.enclosure_id
    WHERE e.enclosure_number = encl;
END;
$$;


CREATE OR REPLACE FUNCTION get_species_by_enclosure(encl INT) -- enclosure number вводим
    RETURNS SETOF species
    STABLE LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT s.*
    FROM placement p, enclosure e, species s
    WHERE e.enclosure_number = encl and e.enclosure_id = p.enclosure_id and p.species_id = s.species_id;
END;
$$;


