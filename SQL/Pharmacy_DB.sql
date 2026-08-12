CREATE DATABASE PharmacyDatabase;
USE PharmacyDatabase;

CREATE TABLE Client
(
	Client_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Full_name NVARCHAR(30) NOT NULL,
	Phone_number NVARCHAR(20) NOT NULL,
	Adress NVARCHAR(50) NOT NULL
);

CREATE TABLE Orders
(
	Order_ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Amount MONEY CHECK (Amount > 0) NOT NULL,
	Order_date DATE NOT NULL
);

CREATE TABLE Medicine
(
	Title NVARCHAR(20) PRIMARY KEY NOT NULL,
	Annotation NVARCHAR(50),
	Indications_for_use NVARCHAR(20) NOT NULL,
	Expiration_date DATE NOT NULL,
	Manufacturer NVARCHAR(20) NOT NULL,
	Active_substance NVARCHAR(20) NOT NULL,
	Unit_price MONEY CHECK (Unit_price > 0) NOT NULL,
	Quantity_in_pharmacy INT NOT NULL CHECK (Quantity_in_pharmacy >= 0)
	CONSTRAINT UQ_Medicine_Title UNIQUE (Title)
); 
ALTER TABLE Medicine
ALTER COLUMN Active_substance NVARCHAR(50) NOT NULL;

ALTER TABLE Medicine
ALTER COLUMN Indications_for_use NVARCHAR(50) NOT NULL;


CREATE TABLE Sale
(
	Sale_ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Cashier_last_name NVARCHAR(20),
	Total_sum MONEY NOT NULL CHECK (Total_sum > 0),
	Date_of_sale DATE NOT NULL,
	Client_ID INT NOT NULL,
	FOREIGN KEY (Client_ID) REFERENCES Client(Client_ID)
);

CREATE TABLE Disease
(
	Disease_ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Disease_type NVARCHAR(20) NOT NULL
);

CREATE TABLE Section
(
	Section_ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Title NVARCHAR(20) NOT NULL
);

CREATE TABLE Symptom
(
	Symptoms_ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Symptoms_name NVARCHAR(20) NOT NULL
);

ALTER TABLE Symptom
ALTER COLUMN Symptoms_name NVARCHAR(50) NOT NULL

CREATE TABLE Disease_symptoms
(
	Disease_ID INT NOT NULL,
	Symptoms_ID INT NOT NULL,
	PRIMARY KEY(Disease_ID, Symptoms_ID),
	FOREIGN KEY (Disease_ID) REFERENCES Disease(Disease_ID),
	FOREIGN KEY (Symptoms_ID) REFERENCES Symptom(Symptoms_ID)
);

CREATE TABLE Sale_medicine
(
	Sale_ID INT NOT NULL,
	Title NVARCHAR(20) NOT NULL,
	Medicine_count INT CHECK (Medicine_count > 0) NOT NULL,
	PRIMARY KEY (Sale_ID, Title),
	FOREIGN KEY (Sale_ID) REFERENCES Sale(Sale_ID) ON DELETE CASCADE,
	FOREIGN KEY (Title) REFERENCES Medicine(Title)
);

CREATE TABLE Medicine_disease
(
	Title NVARCHAR(20) NOT NULL,
	Disease_ID INT NOT NULL,
	PRIMARY KEY (Title, Disease_ID),
	FOREIGN KEY (Title) REFERENCES Medicine(Title),
	FOREIGN KEY (Disease_ID) REFERENCES Disease(Disease_ID)
);

CREATE TABLE Medicine_orders
(
	Title NVARCHAR(20) NOT NULL,
	Order_ID INT NOT NULL,
	PRIMARY KEY (Title, Order_ID),
	FOREIGN KEY (Title) REFERENCES Medicine(Title),
	FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID) ON DELETE CASCADE
);

CREATE TABLE Medicine_section
(
	Section_ID INT NOT NULL,
	Title NVARCHAR(20) NOT NULL,
	PRIMARY KEY (Section_ID, Title),
	FOREIGN KEY (Section_ID) REFERENCES Section(Section_ID),
	FOREIGN KEY (Title) REFERENCES Medicine(Title)
);

INSERT INTO Client(Full_name, Phone_number, Adress)
VALUES
	('Иванов Иван Иванович', '+7(916)123-45-67', 'г. Ярославль, пр-кт Ленина д. 25'),
	('Егорова Татьяна Дмитриевна', '+7(987)654-32-10', 'г. Ярославль, ул. Кирова, д. 15'),
	('Орлова Ксения Денисовна', '+7(905)888-11-22', 'г. Ярославль, пр-т Ленина, д. 87'),
	('Громов Павел Анатольевич', '+7(927)111-22-33', 'г. Ярославль, ул. Свободы, д. 33'),
	('Абрамова Юлия Романовна', '+7(915)777-88-99', 'г. Ярославль, ул. Белинского, д. 12'),
	('Якоелева Алёна Ильинична', '+7(903)345-67-89', 'г. Ярославль, Которосльная наб., д. 41'),
	('Волкова Елена Игоревна', '+7(910)456-78-90', 'г. Ярославль, Ленинградский пр-т, д. 42'),
	('Козлов Сергей Игоревич', '+7(925)234-56-78', 'г. Ярославль, ул. Некрасова, д. 24'),
	('Соколов Денис Юрьевич', '+7(915)345-67-89', 'г. Ярославль, ул. Чкалова, д. 7'),
	('Морозова Ирина Вячеславовна', '+7(905)567-89-01', 'г. Ярославль, ул. Победы, д. 62')

	INSERT INTO Orders(Amount, Order_date)
VALUES
	(2500.00,'2025-05-10'),
	(9900.90,'2025-05-29'),
	(2650.90,'2025-06-12'),
	(4300.70,'2025-06-29'),
	(3700.25,'2025-07-15'),
	(2300.00,'2025-07-30'),
	(9900.90,'2025-08-09'),
	(3200.40,'2025-08-26'),
	(2300.50,'2025-09-10'),
	(950.15,'2025-09-25')


INSERT INTO Medicine(Title, Annotation, Indications_for_use, Expiration_date, Manufacturer,Active_substance, Unit_price, Quantity_in_pharmacy)
VALUES
	('Аспирин', 'Обезболивающее и противовоспалительное', 'Головная боль', '2026-12-31', 'ФармСтандарт','Ацетилсалициловая кислота', 98.50, 45),
	('Парацетамол', 'Жаропонижающее средство', 'Высокая температура', '2026-08-15', 'Фармстандарт', 'Ацетаминофен', 150.50, 120),
	('Но-шпа', 'Спазмолитик', 'Спазмы ЖКТ', '2026-03-20', 'Хиноин', 'Дротаверин', 275.00, 78),
	('Мезим', 'Ферментный препарат', 'Проблемы пищеварения', '2026-01-15', 'Берлин-Хеми', 'Панкреатин',299.99 , 88),
	('Анальгин', 'Анальгетик', 'Боль различного генеза', '2026-02-28', 'Мосхимфарм', 'Метамизол', 110.30, 210),
	('Омепразол', 'Снижает кислотность желудочного сока', 'Изжога', '2026-08-30', 'КРКА', 'Омепразол', 150.99, 72),
	('Фенистил', 'Противоаллергическое', 'Кожные аллергии', '2025-11-25', 'Новартис', 'Диметинден', 145.75, 58),
	('Активированный уголь', 'Адсорбент', 'Отравления', '2026-09-14', 'Фармгрупп', 'Уголь активированный', 45.99, 120),
	('Глицин', 'Ноотропное', 'Стресс, бессонница', '2026-10-30', 'Биотики', 'Глицин', 95.25, 98),
	('Називин', 'Сосудосуживающее для носа', 'Заложенность носа', '2026-09-25', 'Мерк', 'Оксиметазолин', 125.80, 150)


INSERT INTO Medicine (Title, Annotation, Indications_for_use, Expiration_date, Manufacturer, Active_substance, Unit_price, Quantity_in_pharmacy)
VALUES
('Дротаверин-Фарм', 'Спазмолитик', 'Спазмы ЖКТ', '2026-11-30', 'ФармСтандарт', 'Дротаверин', 190.00, 60),
('Спазмалгон', 'Комбинированный спазмолитик и анальгетик', 'Боли различного генеза', '2026-10-15', 'Берлин-Хеми', 'Дротаверин', 240.50, 45);

INSERT INTO Medicine (Title, Annotation, Indications_for_use, Expiration_date, Manufacturer, Active_substance, Unit_price, Quantity_in_pharmacy)
VALUES 
('Стрепсилс', 'Антисептическое средство для горла', 'Боль в горле', '2026-12-31', 'Рекитт Бенкизер', 'Амилметакрезол', 280.00, 50),
('Граммидин', 'Антибактериальный препарат для горла', 'Затрудненное глотание', '2026-10-15', 'Валента Фармацевтика', 'Грамицидин C', 320.50, 35);

UPDATE Medicine 
SET Indications_for_use =  'Затрудненное глотание'
WHERE Title = 'Граммидин'

UPDATE Medicine
SET Indications_for_use = 'Спазмы ЖКТ'
WHERE Title = 'Дротаверин-Фарм'

UPDATE Medicine
SET Indications_for_use = 'Боли различного генеза'
WHERE Title = 'Спазмалгон'

UPDATE Medicine 
SET Manufacturer = 'ФармСтандарт'
WHERE Title = 'Парацетамол'


INSERT INTO Sale(Cashier_last_name, Total_sum, Date_of_sale, Client_ID)
VALUES
	('Емельянова', 156.29, '2025-09-20', 1),
	('Касаткина', 296.25, '2025-09-20', 2),
	('Капустина', 208.80, '2025-09-21', 1),
	('Смирнов', 220.60, '2025-09-21', 4),
	('Емельянова', 251.60, '2025-09-22', 5),
	('Капустина', 171.79, '2025-09-22', 6),
	('Касаткина', 301.49, '2025-09-23', 7),
	('Емельянова', 725.98, '2025-09-23', 8),
	('Смирнов', 401.80, '2025-09-23', 9),
	('Капустина', 313.03, '2025-09-23', 2)

INSERT INTO Sale (Cashier_last_name, Total_sum, Date_of_sale, Client_ID)
VALUES
('Емельянова', 640.50, '2025-09-24', 3),
('Касаткина', 360.00, '2025-09-24', 5)

INSERT INTO Sale(Cashier_last_name, Total_sum, Date_of_sale, Client_ID)
VALUES
('Смирнов', 516.60, '2025-09-30', 10)

INSERT INTO Disease(Disease_type)
VALUES
	('Грипп'),
	('Простуда'),
	('Гастрит'),
	('Отравление'),
	('Аллергия'),
	('Синусит'),
	('Гастроэнтерит'),
	('Бронхит'),
	('Невроз'),
	('Артрит'),
	('Псориаз'),
	('Мышечная дистрофия'),
	('Малярия')

INSERT INTO Disease (Disease_type) 
VALUES ('Ангина');

INSERT INTO Section(Title)
VALUES
	('Обезболивающие' ),
	('Жаропонижающие' ),
	('Противоаллергические' ),
	('Желудочно-кишечные' ),
	('Противовирусные' ),
	('Антибиотики' ),
	('Сердечно-сосудистые' ),
	('Гормональные' ),
	('Успокоительные' ),
	('Капли и спреи' )

	INSERT INTO Symptom(Symptoms_name)
VALUES
	('Лихорадка' ),
	('Насморк' ),
	('Тошнота' ),
	('Рвота' ),
	('Сыпь' ),
	('Заложенность носа' ),
	('Боль в животе' ),
	('Кашель' ),
	('Стресс' ),
	('Боль в суставах' ),
	('Диарея' ),
	('Изжога')

	INSERT INTO Symptom(Symptoms_name)
VALUES
	('Повышенное потоотделение' ),
	('Озноб' ),
	('Кожные бляшки' ),
	('Мышечная слабость' ),
	('Нарушение координации движения' )

INSERT INTO Symptom (Symptoms_name) 
VALUES 
    ('Боль в горле'),
    ('Увеличение миндалин'),
    ('Затрудненное глотание')

INSERT INTO Disease_symptoms(Disease_ID, Symptoms_ID)
VALUES
	(1, 1),
	(2, 2),
	(3, 3),
	(3, 12),
	(4, 4),
	(4, 11),
	(5, 5),
	(6, 6),
	(7, 7),
	(8, 8),
	(9, 9),
	(10, 10)

INSERT INTO Disease_symptoms(Disease_ID, Symptoms_ID)
VALUES
    (14, 1),
    (14, 13)



INSERT INTO Sale_medicine(Sale_ID, Title, Medicine_count)
VALUES
	(1, 'Анальгин', 1),
	(1, 'Активированный уголь', 1),
	(2, 'Парацетамол', 1),
	(2, 'Фенистил', 1),
	(3, 'Аспирин', 1),
	(3, 'Анальгин', 1),
	(4, 'Анальгин', 2),
	(5, 'Називин', 2),
	(6, 'Називин', 1),
	(6, 'Активированный уголь', 1),
	(7, 'Парацетамол', 1),
	(7, 'Омепразол', 1),
	(8, 'Но-шпа', 1),
	(8, 'Мезим', 1),
	(8, 'Омепразол', 1),
	(9, 'Анальгин', 1),
	(9, 'Фенистил', 2),
	(10, 'Активированный уголь', 2),
	(10, 'Глицин', 1),
	(10, 'Називин', 1);

INSERT INTO Sale_medicine (Sale_ID, Title, Medicine_count)
VALUES
(11, 'Граммидин', 2), 
(12, 'Дротаверин-Фарм', 2);

INSERT INTO Medicine_disease(Title, Disease_ID)
VALUES
	('Аспирин', 1),
	('Аспирин', 2),
	('Парацетамол', 2),
	('Но-шпа', 3),
	('Омепразол', 3),
	('Активированный уголь', 4),
	('Фенистил', 5),
	('Називин', 6),
	('Омепразол', 7),
	('Мезим', 7),
	('Анальгин', 8),
	('Глицин', 9),
	('Анальгин', 10)

INSERT INTO Medicine_disease (Title, Disease_ID)
VALUES
('Дротаверин-Фарм', 3), 
('Дротаверин-Фарм', 7),
('Спазмалгон', 3),     
('Спазмалгон', 10)

INSERT INTO Medicine_disease (Title, Disease_ID)
VALUES 
('Стрепсилс', 14),
('Граммидин', 14);

INSERT INTO Medicine_orders(Title, Order_ID)
VALUES
	('Аспирин', 1),
	('Парацетамол', 1),
	('Но-шпа', 2),
	('Мезим', 2),
	('Анальгин', 3),
	('Омепразол', 3),
	('Фенистил', 4),
    ('Активированный уголь', 4),
    ('Глицин', 5),
    ('Називин', 5),
    ('Аспирин', 6),
    ('Називин', 6),
    ('Но-шпа', 7),
    ('Мезим', 7),
    ('Анальгин', 8),
    ('Омепразол', 8),
    ('Глицин', 9),
    ('Називин', 9),
    ('Активированный уголь', 10),
    ('Глицин', 10)

INSERT INTO Medicine_section(Section_ID, Title)
VALUES
	(1, 'Аспирин'),        
	(1, 'Анальгин'),       
	(2, 'Парацетамол'),      
	(2, 'Аспирин'), 
	(3, 'Фенистил'),      
	(4, 'Но-шпа'),          
	(4, 'Мезим'),            
	(4, 'Омепразол'),        
	(4, 'Активированный уголь'),
	(5, 'Анальгин'),
	(6, 'Анальгин'),
	(9, 'Глицин'),           
	(10, 'Називин')

INSERT INTO Medicine_section (Section_ID, Title)
VALUES
(4, 'Дротаверин-Фарм'),
(4, 'Спазмалгон'), 
(1, 'Спазмалгон')

DELETE FROM Orders
WHERE Order_date = '2025-11-11'

DELETE FROM Orders
WHERE Order_ID > 11
DELETE FROM Medicine_orders
WHERE Order_ID > 11

UPDATE Medicine
SET Quantity_in_pharmacy = 340
WHERE Title = 'Називин'

SELECT * FROM Client
SELECT * FROM Orders
SELECT * FROM Medicine
SELECT * FROM Sale
SELECT * FROM Disease
SELECT * FROM Section
SELECT * FROM Symptom
SELECT * FROM Disease_symptoms
SELECT * FROM Sale_medicine
SELECT * FROM Medicine_disease
SELECT * FROM Medicine_orders
SELECT * FROM Medicine_section

SELECT * FROM Medicine
SELECT * FROM Sale
SELECT * FROM Sale_medicine
