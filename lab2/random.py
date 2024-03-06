from faker import Faker
import psycopg2
import random

# Создание подключения к базе данных
conn = psycopg2.connect(dbname="zoo", user="postgres", password="f8ysz789", host="127.0.0.1")
cur = conn.cursor()

# Создание экземпляра Faker
fake = Faker()

# Генерация и вставка данных в таблицу species
number_of_species = 0
for _ in range(1, 50):
    species_name = fake.last_name()
    hab = ("grassland", "polar", "desert", "mountain", "freshwater", "ocean", "rainforest" )
    habitat = random.choice(hab)
    family_name = fake.first_name()
    lifespan = random.randint(5, 90)

    # Проверка на уникальность значения поля "species_name"
    query = "SELECT count(*) FROM species WHERE species_name = %s"
    values = (species_name,)
    cur.execute(query, values)
    result = cur.fetchone()
    if result[0] > 0:
        continue
    number_of_species += 1
    species_id = number_of_species
    query = "INSERT INTO species (species_name, habitat, family_name, lifespan) VALUES (%s, %s, %s, %s)"
    values = (species_name, habitat, family_name, lifespan)
    cur.execute(query, values)
# Генерация и вставка данных в таблицу enclosure
for _ in range(1, 50):
    enclosure_id = _
    enclosure_number = _ + 3
    square = random.randint(5, 100)
    enclosure_name = fake.company()  # название комплекса
    b = (True, False)
    reservoir_availability = random.choice(b)

    query = "INSERT INTO enclosure (enclosure_number, square, enclosure_name, reservoir_availability) VALUES (%s, %s, %s, %s)"
    values = (enclosure_number, square, enclosure_name, reservoir_availability)
    cur.execute(query, values)
# Генерация и вставка данных в таблицу animal
for _ in range(1, 1001):
    animal_id = _
    animal_name = fake.first_name()
    birth_date = fake.date()
    species_id = random.randint(1, number_of_species)
    enclosure_id = random.randint(1, 30)

    # SQL-запрос для вставки данных
    query = "INSERT INTO animal (animal_name, birth_date, species_id, enclosure_id) VALUES (%s, %s, %s, %s)"
    values = (animal_name, birth_date, species_id, enclosure_id)
    # Выполнение SQL-запроса
    cur.execute(query, values)
# Генерация и вставка данных в таблицу employee
for _ in range(1, 51):
    employee_id = _
    employee_name = fake.name()
    role = ("clean", "wash", "photo", "video", "feed", "play", "guide")
    employee_role = random.choice(role)
    enclosure_id = random.randint(1, 30)

    query = "INSERT INTO employee (employee_name, employee_role, enclosure_id) VALUES (%s, %s, %s)"
    values = (employee_name, employee_role, enclosure_id)
    cur.execute(query, values)
# Генерация и вставка данных в таблицу placement
for _ in range(1, 31):
    placement_id = _
    number_of_animals = random.randint(1,5)
    species_id = random.randint(1, number_of_species)
    enclosure_id = random.randint(1, 30)

    query = "INSERT INTO placement (number_of_animals, species_id, enclosure_id) VALUES (%s, %s, %s)"
    values = (number_of_animals, species_id, enclosure_id)
    cur.execute(query, values)
# Подтверждение изменений и закрытие подключения
conn.commit()
cur.close()
conn.close()
