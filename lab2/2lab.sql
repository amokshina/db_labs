create table species
(species_id serial PRIMARY KEY,
 lifespan integer CHECK(lifespan > 0),
 species_name varchar NOT NULL,
 habibat varchar NOT NULL,
 family_name varchar NOT NULL);
 
 create table animal
(animal_id serial PRIMARY KEY,
 animal_name varchar NOT NULL,
 birth_date date NOT NULL,
 species_id integer NOT NULL,
 enclosure_id integer NOT NULL); 

create table placement
(placement_id serial PRIMARY KEY,
 number_of_animals integer CHECK(number_of_animals > 0),
 species_id integer NOT NULL,
 enclosure_id integer NOT NULL);

create table enclosure
(enclosure_id serial PRIMARY KEY,
 enclosure_number integer CHECK(enclosure_number > 0),
 square integer CHECK(square > 0),
 enclosure_name varchar NOT NULL,
 reservoir_availability boolean NOT NULL);
 
 create table employee
 (employee_id serial PRIMARY KEY,
 employee_name varchar NOT NULL,
 employee_role varchar NOT NULL,
 enclosure_id integer NOT NULL);

ALTER TABLE animal
ADD FOREIGN KEY(species_id) REFERENCES species(species_id),
ADD FOREIGN KEY(enclosure_id) REFERENCES enclosure(enclosure_id);

ALTER TABLE employee
ADD FOREIGN KEY(enclosure_id) REFERENCES enclosure(enclosure_id);

ALTER TABLE enclosure
ADD UNIQUE(enclosure_number);

ALTER TABLE placement
ADD FOREIGN KEY(species_id) REFERENCES species(species_id),
ADD FOREIGN KEY(enclosure_id) REFERENCES enclosure(enclosure_id);

ALTER TABLE species
ADD UNIQUE(species_name);

ALTER TABLE species
RENAME COLUMN habibat TO habitat;

