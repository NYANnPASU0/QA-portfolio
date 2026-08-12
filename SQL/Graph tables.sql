USE PharmacyDatabase;
GO

-- Графовые таблицы
--таблицы узлов
CREATE TABLE G_Client
(
	Client_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Full_name NVARCHAR(30) NOT NULL,
	Phone_number NVARCHAR(20) NOT NULL,
	Adress NVARCHAR(50) NOT NULL
) AS NODE


CREATE TABLE G_Orders
(
    Order_ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Amount MONEY CHECK (Amount > 0) NOT NULL,
	Order_date DATE NOT NULL
) AS NODE


CREATE TABLE G_Medicine (
    Title NVARCHAR(20) PRIMARY KEY,
    Annotation NVARCHAR(50),
    Indications_for_use NVARCHAR(50) NOT NULL,
    Expiration_date DATE NOT NULL,
    Manufacturer NVARCHAR(20) NOT NULL,
    Active_substance NVARCHAR(50) NOT NULL,
    Unit_price MONEY NOT NULL,
    Quantity_in_pharmacy INT NOT NULL
) AS NODE


CREATE TABLE G_Sale
(
	Sale_ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Cashier_last_name NVARCHAR(20),
	Total_sum MONEY NOT NULL CHECK (Total_sum > 0),
	Date_of_sale DATE NOT NULL,
	Client_ID INT NOT NULL
) AS NODE


CREATE TABLE G_Disease
(
	Disease_ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Disease_type NVARCHAR(20) NOT NULL
) AS NODE


CREATE TABLE G_Section
(
	Section_ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Title NVARCHAR(20) NOT NULL
) AS NODE


CREATE TABLE G_Symptom
(
	Symptoms_ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Symptoms_name NVARCHAR(50) NOT NULL
) AS NODE

--таблицы ребер
CREATE TABLE disease_has_symptom AS EDGE --disease <- disease_symptoms -> symptom

CREATE TABLE sale_of_medicine
(
	Medicine_count INT CHECK (Medicine_count > 0) NOT NULL
) AS EDGE --sale <- sale_medicine -> medicine

CREATE TABLE medicine_cures_disease AS EDGE --medicine <- medicine_disease -> disease

CREATE TABLE order_contains_medicine AS EDGE --orders <- medicine_orders -> medicine

CREATE TABLE medicine_in_section AS EDGE --medicine <- medicine_section --> section

CREATE TABLE client_bought_medicine AS EDGE --client <- bought -> sale


--заполнение таблиц узлов
INSERT INTO G_Client(Full_name, Phone_number, Adress)
SELECT Full_name, Phone_number, Adress
FROM Client

INSERT INTO G_Orders(Amount, Order_date)
SELECT Amount, Order_date
FROM Orders

INSERT INTO G_Medicine(Title, Annotation, Indications_for_use, Expiration_date, Manufacturer, Active_substance, Unit_price, Quantity_in_pharmacy)
SELECT Title, Annotation, Indications_for_use, Expiration_date, Manufacturer, Active_substance, Unit_price, Quantity_in_pharmacy
FROM Medicine

INSERT INTO G_Sale(Cashier_last_name, Total_sum, Date_of_sale, Client_ID)
SELECT Cashier_last_name, Total_sum, Date_of_sale, Client_ID
FROM Sale

INSERT INTO G_Disease(Disease_type)
SELECT Disease_type
FROM Disease

INSERT INTO G_Section( Title)
SELECT Title
FROM Section

INSERT INTO G_Symptom(Symptoms_name)
SELECT Symptoms_name
FROM Symptom

--
INSERT INTO disease_has_symptom($from_id, $to_id)
SELECT d.$node_id, s.$node_id
FROM Disease_symptoms ds
JOIN G_Disease d ON d.Disease_ID = ds.Disease_ID
JOIN G_Symptom s ON s.Symptoms_ID = ds.Symptoms_ID

INSERT INTO sale_of_medicine($from_id, $to_id, Medicine_count)
SELECT s.$node_id, m.$node_id, sm.Medicine_count 
FROM Sale_medicine sm
JOIN G_Sale s ON s.Sale_ID = sm.Sale_ID
JOIN G_Medicine m ON m.Title = sm.Title

INSERT INTO medicine_cures_disease($from_id, $to_id)
SELECT m.$node_id, d.$node_id
FROM Medicine_disease md
JOIN G_Medicine m ON m.Title = md.Title
JOIN G_Disease d ON d.Disease_ID = md.Disease_ID

INSERT INTO order_contains_medicine($from_id, $to_id)
SELECT m.$node_id, o.$node_id
FROM Medicine_orders mo
JOIN G_Medicine m ON m.Title = mo.Title
JOIN G_Orders o ON o.Order_ID = mo.Order_ID

INSERT INTO medicine_in_section($from_id, $to_id)
SELECT m.$node_id, s.$node_id
FROM Medicine_section ms
JOIN G_Medicine m ON m.Title = ms.Title
JOIN G_Section s ON s.Section_ID = ms.Section_ID

INSERT INTO sale_have_client($from_id, $to_id)
SELECT c.$node_id, s.$node_id
FROM G_Sale s
JOIN G_Client c ON c.Client_ID = s.Client_ID


--1.) Найти всех производителей, чьи лекарства имеются на данный момент в аптеке
SELECT Manufacturer
FROM Medicine
WHERE Quantity_in_pharmacy > 0


SELECT m.Manufacturer AS Производитель
FROM G_Medicine m
WHERE m.Quantity_in_pharmacy > 0

--2.) Вывести заболевания, для которых в аптеке нет лекарств
-- Находим заболевания, которые НЕ связаны с лекарствами через medicine_cures_disease
SELECT d.Disease_type, d.Disease_ID, md.Title
FROM Disease d LEFT JOIN Medicine_disease md
ON md.Disease_ID = d.Disease_ID
WHERE md.Title IS NULL 


SELECT d.Disease_ID AS ID, d.Disease_type AS Заболевание
FROM G_Disease d
WHERE NOT EXISTS (
    SELECT 1 
    FROM G_Medicine m, medicine_cures_disease mcd
    WHERE MATCH(m-(mcd)->d))

--3.) Найти самые дешевые лекарства с основным действующим веществом «дротаверин»
SELECT m.Title, m.Active_substance, m.Unit_price
FROM Medicine m 
WHERE m.Active_substance = 'дротаверин'
ORDER BY m.Unit_price ASC


SELECT m.Title, m.Active_substance, m.Unit_price
FROM G_Medicine m 
WHERE m.Active_substance = 'дротаверин'
ORDER BY m.Unit_price ASC

--4.) Найти все лекарства от ангины и насморка
SELECT md.Title,s.Symptoms_name, d.Disease_type
FROM Medicine_disease md 
LEFT JOIN Disease d ON md.Disease_ID = d.Disease_ID
LEFT JOIN Disease_symptoms ds ON d.Disease_ID = ds.Disease_ID
LEFT JOIN Symptom s ON ds.Symptoms_ID = s.Symptoms_ID
WHERE s.Symptoms_name = 'Насморк' OR d.Disease_type = 'Ангина'


SELECT DISTINCT m.Title AS Лекарство, d.Disease_type AS Заболевание, s.Symptoms_name AS Симптом
FROM G_Medicine m, G_Disease d, medicine_cures_disease mcd, disease_has_symptom ds, G_Symptom s
WHERE MATCH(m-(mcd)->d-(ds)->s) AND (d.Disease_type = 'Ангина' OR s.Symptoms_name = 'Насморк')

--5.) Для каждого лекарства вывести количество проданных с начала года упаковок с упорядочением кол-ва упаковок по убыванию
SELECT sm.Title AS Лекарство , SUM(sm.Medicine_count) AS Количество, YEAR(GETDATE()) AS Год_продажи
FROM Medicine m
LEFT JOIN Sale_Medicine sm ON m.Title = sm.Title
LEFT JOIN Sale s ON s.Sale_ID = sm.Sale_ID
WHERE YEAR(s.Date_of_sale) = YEAR(GETDATE())
GROUP BY sm.Title
ORDER BY SUM(sm.Medicine_count) DESC


SELECT m.Title AS Лекарство, SUM(som.Medicine_count) AS [Кол-во проданных упаковок], YEAR(s.Date_of_sale) AS [Год продажи]
FROM G_Medicine m, sale_of_medicine som, G_Sale s
WHERE MATCH( s-(som)->m) AND YEAR(s.Date_of_sale) = YEAR(GETDATE())
GROUP BY m.Title, YEAR(s.Date_of_sale)
ORDER BY SUM(som.Medicine_count) DESC

--6.) Выдать выручку аптеки за вчерашний день по каждому разделу лекарств
SELECT sect.Title AS Раздел, SUM(sm.Medicine_count * m.Unit_price) AS Выручка, s.Sale_ID AS [ID продажи] ,MAX(s.Date_of_sale) AS [Дата продажи]
FROM Sale s
LEFT JOIN Sale_medicine sm ON s.Sale_ID = sm.Sale_ID
LEFT JOIN Medicine m ON sm.Title = m.Title
LEFT JOIN Medicine_section ms ON m.Title = ms.Title
LEFT JOIN Section sect ON ms.Section_ID = sect.Section_ID
WHERE s.Date_of_sale = (
	SELECT DATEADD(DAY, -1, MAX(s.Date_of_sale))
	FROM Sale s)
GROUP BY sect.Title, s.Sale_ID


SELECT sect.Title AS Раздел, SUM(som.Medicine_count * m.Unit_price) AS Выручка,
s.Sale_ID AS [ID продажи], MAX(s.Date_of_sale) AS [Дата продажи]
FROM G_Sale s, sale_of_medicine som, G_Medicine m, medicine_in_section mis, G_Section sect
WHERE MATCH(s-(som)->m-(mis)->sect) AND s.Date_of_sale = (
	SELECT MAX(Date_of_sale) 
    FROM G_Sale 
    WHERE Date_of_sale < (SELECT MAX(Date_of_sale) FROM G_Sale))
	--WHERE s.Date_of_sale = (
	--SELECT DATEADD(DAY, -1, CAST(GETDATE() AS DATE)
	--FROM G_Sale)
GROUP BY sect.Title, s.Sale_ID
