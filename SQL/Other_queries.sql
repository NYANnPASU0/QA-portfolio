USE PharmacyDatabase
GO

--1. Выборка из одной таблицы
--1.1
SELECT Title AS Название, Manufacturer AS Прозводитель,
Unit_price AS [Цена за единицу], Quantity_in_pharmacy AS [Количество в аптеке]
FROM Medicine
ORDER BY Unit_price ASC, Quantity_in_pharmacy DESC


--1.2
--1)
SELECT *
FROM Medicine 
WHERE Active_substance = 'Дротаверин'
--2)
SELECT *
FROM Medicine
WHERE Unit_price BETWEEN 100 AND 300
--3)
SELECT * 
FROM Orders
WHERE Amount > 3500


--1.3
--1)
SELECT COUNT(Sale_ID) AS [Количество продаж], SUM(Total_sum) AS Выручка,
		AVG(Total_sum) AS [Средний чек], MAX(Total_sum) AS [Макс.цена продажи],
		MIN(Total_sum) AS [Мин.цена продажи]
FROM Sale
--2)
SELECT  Cashier_last_name AS [Фамилия кассира], COUNT(Sale_ID) AS [Количество продаж], 
		SUM(Total_sum) AS Выручка, AVG(Total_sum) AS [Средний чек]
FROM Sale
GROUP BY Cashier_last_name
--3)
SELECT Manufacturer AS Производитель, COUNT(Title) AS [Количество препаратов],
SUM(Quantity_in_pharmacy) AS [Количество в аптеке], AVG(Unit_price) AS [Средняя цена],
MAX(Unit_price) AS [Самое дорогое лекарство], MIN(Unit_price) AS [Самое дешевое лекарство]
FROM Medicine
GROUP BY Manufacturer

--1.4
--GROUP BY ALL
--1)
SELECT Manufacturer AS Производитель, COUNT(Title) AS [Всего препаратов]
FROM Medicine
WHERE Unit_price > 100
GROUP BY ALL Manufacturer
--2)
SELECT  Cashier_last_name AS Кассир, COUNT(Sale_ID) AS [Количество продаж]
FROM Sale
WHERE Total_sum > 300
GROUP BY ALL Cashier_last_name


--ROLLUP
--3)
SELECT ISNULL(s.Cashier_last_name, 'ALL') AS Кассир, ISNULL(c.Full_name, 'Всего покупателей') AS Клиент,
COUNT(s.Sale_ID) AS [Количество продаж], SUM(s.Total_sum) AS [Общая сумма]
FROM Sale s
JOIN Client c ON s.Client_ID = c.Client_ID
GROUP BY ROLLUP (Cashier_last_name, c.Full_name)
--4)
SELECT ISNULL(Manufacturer, 'ALL') AS Производитель, COUNT(Title) AS [Количество лекарств],
SUM(Quantity_in_pharmacy) AS [Запас в аптеке]
FROM Medicine
WHERE  Manufacturer IN ('Берлин-Хеми', 'ФармСтандарт')
GROUP BY ROLLUP (Manufacturer, Active_substance)

--CUBE
--5)
SELECT ISNULL(Manufacturer, 'ALL') AS Производитель,
COUNT(Title) AS [Количество лекарств], SUM(Quantity_in_pharmacy) AS [Запас в аптеке]
FROM Medicine
WHERE  Manufacturer IN ('Берлин-Хеми', 'КРКА', 'ФармСтандарт')
GROUP BY CUBE (Manufacturer, Active_substance)
--6)
SELECT ISNULL(Cashier_last_name, 'Все кассиры') AS Кассир,
ISNULL(CAST(Date_of_sale AS VARCHAR(10)), 'ВСЕ ДАТЫ') AS Дата,
COUNT(Sale_ID) AS [Количество продаж], SUM(Total_sum) AS [Общая выручка]
FROM Sale
GROUP BY CUBE (Cashier_last_name, Date_of_sale);

--1.5
--Medicine
--Названия лекарств
SELECT Title AS Название, Manufacturer AS Производитель,
Active_substance AS [Действующее вещество], Unit_price AS [Цена за единицу],
Quantity_in_pharmacy AS [Количество в аптеке]
FROM Medicine
WHERE Title NOT LIKE '%ин%'
ORDER BY Title
--Производитель
SELECT Title AS Название, Manufacturer AS Производитель,
Active_substance AS [Действующее вещество], Unit_price AS [Цена за единицу],
Quantity_in_pharmacy AS [Количество в аптеке]
FROM Medicine
WHERE Manufacturer NOT LIKE '%Фарм%'
ORDER BY Manufacturer
--Действующее вещество
SELECT Title AS Название, Manufacturer AS Производитель,
Active_substance AS [Действующее вещество], Unit_price AS [Цена за единицу],
Quantity_in_pharmacy AS [Количество в аптеке]
FROM Medicine
WHERE Active_substance NOT LIKE 'О%' AND Active_substance NOT LIKE 'Д%'
ORDER BY Active_substance


--Disease
SELECT * 
FROM Disease
WHERE Disease_type NOT LIKE '%ит%'

--Symptoms
SELECT * 
FROM Symptom
WHERE Symptoms_name NOT LIKE '%боль%'

--Section
SELECT * 
FROM Section
WHERE Title NOT LIKE '%ие'

--CLient
SELECT * 
FROM Client
WHERE Full_name NOT LIKE '%вна'

--2. Выборка из нескольких таблиц
--2.1
--1)
SELECT m.Title AS Лекарство, s.Title AS Раздел
FROM Medicine_section ms, Medicine m, Section s
WHERE ms.Title = m.Title  AND ms.Section_ID = s.Section_ID
--2)
SELECT s.Symptoms_name AS Симптом, d.Disease_type AS Болезнь
FROM Symptom s, Disease d, Disease_symptoms ds
WHERE s.Symptoms_ID = ds.Symptoms_ID AND ds.Disease_ID = d.Disease_ID
--3)
SELECT m.Title, d.Disease_type
FROM Medicine m, Disease d, Medicine_disease md
WHERE md.Disease_ID = d.Disease_ID AND md.Title = m.Title


--2.2
--1)
SELECT m.Title AS Лекарство, s.Title AS Раздел
FROM Medicine m
INNER JOIN Medicine_section ms ON ms.Title = m.Title
INNER JOIN Section s ON s.Section_ID = ms.Section_ID
--2)
SELECT s.Symptoms_name AS Симптом, d.Disease_type AS Болезнь
FROM Symptom s
INNER JOIN Disease_symptoms ds ON ds.Symptoms_ID = s.Symptoms_ID
INNER JOIN Disease d ON d.Disease_ID = ds.Disease_ID
--3)
SELECT m.Title, d.Disease_type
FROM Medicine m
INNER JOIN Medicine_disease md ON md.Title = m.Title
INNER JOIN Disease d ON d.Disease_ID = md.Disease_ID


--2.3
--1)
SELECT m.Title AS Лекарство, m.Unit_price AS [Цена за ед.], s.Title AS Раздел
FROM Medicine m
LEFT JOIN Medicine_section ms ON ms.Title = m.Title
LEFT JOIN Section s ON s.Section_ID = ms.Section_ID

--2)
SELECT m.Title AS Лекарство, m.Unit_price AS [Цена за ед.], d.Disease_type AS Болезнь
FROM Medicine m
LEFT JOIN Medicine_disease md ON md.Title = m.Title
LEFT JOIN Disease d ON md.Disease_ID = d.Disease_ID

--2.4
--1)
SELECT s.Sale_ID AS [ID продажи], s.Total_sum AS Сумма, c.Full_name AS Клиент
FROM Client c
RIGHT JOIN Sale s ON c.Client_ID = s.Client_ID
--2)
SELECT o.Order_ID AS [ID заказа], o.Amount AS Сумма, m.Title AS Лекарство
FROM Medicine m
RIGHT JOIN Medicine_orders mo ON m.Title = mo.Title
RIGHT JOIN Orders o ON mo.Order_ID = o.Order_ID
--3)
SELECT m.Title AS Лекарство,s.Title AS Раздел
FROM Medicine m
RIGHT JOIN Medicine_section ms ON m.Title = ms.Title
RIGHT JOIN Section s ON ms.Section_ID = s.Section_ID


--2.5
--1)
SELECT Cashier_last_name AS [Фамилия кассира], COUNT(Cashier_last_name) AS [Кол-во продаж], SUM(Total_sum) AS [Сумма продаж]
FROM Sale
GROUP BY Cashier_last_name
--2)
SELECT  m.Title AS Лекарство, SUM(sm.Medicine_count) AS [Всего продано упаковок],
SUM(sm.Medicine_count * m.Unit_price) AS [Общая сумма продаж]
FROM Medicine m
JOIN Sale_medicine sm ON m.Title = sm.Title
GROUP BY m.Title
--3)
SELECT c.Full_name AS Клиент, COUNT(s.Sale_ID) AS [Количество покупок],SUM(s.Total_sum) AS [Общая сумма покупок]
FROM Client c
JOIN Sale s ON c.Client_ID = s.Client_ID
GROUP BY c.Full_name

--2.6
--1)
SELECT Cashier_last_name AS [Фамилия кассира], COUNT(Cashier_last_name) AS [Кол-во продаж],
SUM(Total_sum) AS [Сумма продаж]
FROM Sale
GROUP BY Cashier_last_name
HAVING COUNT(Cashier_last_name) > 3 AND SUM(Total_sum) > 400
--2)
SELECT  m.Title AS Лекарство, SUM(sm.Medicine_count) AS [Всего продано упаковок], 
SUM(sm.Medicine_count * m.Unit_price) AS [Общая сумма продаж]
FROM Medicine m
JOIN Sale_medicine sm ON m.Title = sm.Title
GROUP BY m.Title
HAVING m.Title LIKE '%ин%' AND SUM(sm.Medicine_count) > 1
--3)
SELECT c.Full_name AS Клиент, COUNT(s.Sale_ID) AS [Количество покупок], 
SUM(s.Total_sum) AS [Общая сумма покупок]
FROM Client c
JOIN Sale s ON c.Client_ID = s.Client_ID
GROUP BY c.Full_name
HAVING c.Full_name NOT LIKE '%ич'

--2.7
--1)
SELECT c.Client_ID AS [ID клиента ], Full_name AS Клиент, s.Date_of_sale AS Дата
FROM Client c
JOIN Sale s ON c.Client_ID = s.Client_ID
WHERE s.Sale_ID IN (
	SELECT sm.Sale_ID
    FROM Sale_medicine sm
    JOIN Medicine_disease md ON sm.Title = md.Title
    JOIN Disease d ON md.Disease_ID = d.Disease_ID
    WHERE d.Disease_type = 'Гастрит'
)

--2)
SELECT m.Title AS Лекарство, m.Active_substance AS [Действующее вещество], 
m.Unit_price AS [Цена за ед.], m.Manufacturer AS Производитель
FROM Medicine m
WHERE EXISTS (
	SELECT *
	FROM Medicine_disease md
    JOIN Disease d ON md.Disease_ID = d.Disease_ID
    JOIN Disease_symptoms ds ON d.Disease_ID = ds.Disease_ID
    JOIN Symptom s ON ds.Symptoms_ID = s.Symptoms_ID
    WHERE md.Title = m.Title AND s.Symptoms_name = 'Лихорадка'
)

--3)
SELECT c.Full_name AS Клиент, s.Date_of_sale AS Дата, s.Total_sum AS Сумма
FROM Client c
JOIN Sale s ON c.Client_ID = s.Client_ID
WHERE s.Total_sum = (
	SELECT MAX(s1.Total_sum)
    FROM Sale s1
    WHERE s1.Client_ID = c.Client_ID
)



--3. Представления
--3.1
--1)
IF OBJECT_ID('Cashiers_sale', 'V') IS NOT NULL
    DROP VIEW Cashiers_sale;
GO

CREATE VIEW Cashiers_sale AS 
SELECT Cashier_last_name AS [Фамилия кассира], COUNT(Cashier_last_name) AS [Кол-во продаж],
SUM(Total_sum) AS [Сумма продаж]
FROM Sale
GROUP BY Cashier_last_name
HAVING COUNT(Cashier_last_name) > 3 AND SUM(Total_sum) > 400
GO
SELECT * FROM Cashiers_sale;
GO

----2)
IF OBJECT_ID('Medicine_sale', 'V') IS NOT NULL
    DROP VIEW Medicine_sale;
GO
 
CREATE VIEW Medicine_sale AS
SELECT  m.Title AS Лекарство, SUM(sm.Medicine_count) AS [Всего продано упаковок],
SUM(sm.Medicine_count * m.Unit_price) AS [Общая сумма продаж]
FROM Medicine m
JOIN Sale_medicine sm ON m.Title = sm.Title
GROUP BY m.Title
HAVING m.Title LIKE '%ин%' AND SUM(sm.Medicine_count) > 2
GO
SELECT * FROM Medicine_sale;
GO

--3.2
--анализ клиентов
--1)
WITH client_analys (Id_client, Fio, Count_purchase, Spent_money) AS (
SELECT c.Client_ID AS Id_client, c.Full_name AS Fio,
	COUNT(s.Sale_ID) AS Count_purchase, SUM(s.Total_sum) AS Spent_money
    FROM Client c
    LEFT JOIN Sale s ON c.Client_ID = s.Client_ID
    GROUP BY c.Client_ID, c.Full_name )
SELECT Id_client AS [ID клиента], Fio AS [ФИО Клиента],
Count_purchase AS [Кол-во покупок], Spent_money AS [Всего денег потрачено]
FROM client_analys

--анализ лекарств по разделам
--2)
WITH Sect_stats (Sect_name, Count_title, Total_quantity, Avg_price, All_price) AS (
SELECT s.Title AS Sect_name, COUNT(m.Title) AS Count_title,
	SUM(m.Quantity_in_pharmacy) AS Total_quantity, AVG(m.Unit_price) AS Avg_price,
    SUM(m.Unit_price * m.Quantity_in_pharmacy) AS All_price
    FROM Section s
    JOIN Medicine_section ms ON s.Section_ID = ms.Section_ID
    JOIN Medicine m ON ms.Title = m.Title
    GROUP BY s.Title )
SELECT Sect_name AS Раздел, Count_title AS [Кол-во препаратов],
Total_quantity AS Запасы, Avg_price AS [Средняя цена], All_price AS [Стоимость запасов]
FROM Sect_stats

--3)
WITH Sales_stats (Last_name, Count_of_sale, Total_revenue, Avg_revenue) AS (
SELECT Cashier_last_name AS Last_name, COUNT(Sale_ID) AS Count_of_sale,
	SUM(Total_sum) AS Total_revenue, AVG(Total_sum) AS Avg_revenue
    FROM Sale
    GROUP BY Cashier_last_name )
SELECT Last_name AS [Фамилия кассира], Count_of_sale AS [Кол-во продаж],
Total_revenue AS [Общая выручка], Avg_revenue AS [Средний чек]
FROM  Sales_stats
ORDER BY Total_revenue DESC


--4. Функции ранжирования
--4.1 
--ROW_NUMBER() 
--без PARTITION BY
--1)
SELECT ROW_NUMBER() OVER (ORDER BY m.Unit_price DESC) AS num,
m.Title AS Лекарство, m.Unit_price AS [Цена за ед.],
d.Disease_type AS Болезнь
FROM Medicine m
LEFT JOIN Medicine_disease md ON md.Title = m.Title
LEFT JOIN Disease d ON md.Disease_ID = d.Disease_ID
--с PARTITION BY
--2)
SELECT ROW_NUMBER() OVER (PARTITION BY d.Disease_type ORDER BY m.Unit_price DESC) AS num,
m.Title AS Лекарство, m.Unit_price AS [Цена за ед.], d.Disease_type AS Болезнь
FROM Medicine m
LEFT JOIN Medicine_disease md ON md.Title = m.Title
LEFT JOIN Disease d ON md.Disease_ID = d.Disease_ID

--RANK()
--без PARTITION BY
--3)
SELECT RANK() OVER(ORDER BY COUNT(m.Title) DESC) AS num,
s.Title AS Раздел, COUNT(m.Title) AS [Кол-во препаратов], SUM(m.Quantity_in_pharmacy) AS [Запасы],
AVG(m.Unit_price) AS [Средняя цена]
FROM Section s
JOIN Medicine_section ms ON s.Section_ID = ms.Section_ID
JOIN Medicine m ON ms.Title = m.Title
GROUP BY s.Title 
--DENSE_RANK()
--4)
--без PARTITION BY
SELECT DENSE_RANK() OVER (ORDER BY SUM(sm.Medicine_count) DESC) AS num, m.Title AS Лекарство,
SUM(sm.Medicine_count) AS [Всего продано упаковок],
SUM(sm.Medicine_count * m.Unit_price) AS [Общая сумма продаж]
FROM Medicine m
JOIN Sale_medicine sm ON m.Title = sm.Title
GROUP BY m.Title
--с PARTITION BY
--5)
SELECT DENSE_RANK() OVER (PARTITION BY s.Title ORDER BY SUM(sm.Medicine_count) DESC) AS num,
m.Title AS Лекарство, s.Title AS Раздел, SUM(sm.Medicine_count) AS [Всего продано упаковок],
SUM(sm.Medicine_count * m.Unit_price) AS [Общая сумма продаж]
FROM Medicine m
JOIN Sale_medicine sm ON m.Title = sm.Title
JOIN Medicine_section md ON md.Title = m.Title
JOIN Section S ON md.Section_ID = s.Section_ID
GROUP BY m.Title, s.Title

--5.Объдинение, пересечение, разность
--UNION ALL
--1)
SELECT Title AS [Название лекарства], Unit_price AS [Цена за ед.], 'Дороже 150' AS Category
FROM Medicine 
WHERE Unit_price > 150
UNION ALL
SELECT m.Title, m.Unit_price, 'От гастрита'
FROM Medicine m
JOIN Medicine_disease md ON m.Title = md.Title
JOIN Disease d ON md.Disease_ID = d.Disease_ID
WHERE d.Disease_type = 'Гастрит'
ORDER BY Unit_price DESC

--EXCEPT
--2)
SELECT Title AS Лекарство, Manufacturer AS Производитель,
Unit_price AS [Цена за ед.], Quantity_in_pharmacy AS [Кол-во в аптеке]
FROM Medicine 
EXCEPT
SELECT m.Title, m.Manufacturer, m.Unit_price, m.Quantity_in_pharmacy
FROM Medicine m
JOIN Sale_medicine sm ON m.Title = sm.Title

--INTERSECT
--3)
SELECT m.Title AS Лекарство, m.Active_substance AS [Действующее вещество],
m.Unit_price AS [Цена за ед.], STRING_AGG(s.Title, ', ') AS Разделы, 'Универсальное' AS Тип
FROM Medicine m
JOIN Medicine_section ms ON m.Title = ms.Title
JOIN Section s ON ms.Section_ID = s.Section_ID
WHERE m.Title IN (
    SELECT m1.Title
    FROM Medicine m1
    JOIN Medicine_section ms1 ON m1.Title = ms1.Title
    JOIN Section s1 ON ms1.Section_ID = s1.Section_ID
    WHERE s1.Title = 'Обезболивающие'
    INTERSECT
    SELECT m2.Title
    FROM Medicine m2
    JOIN Medicine_section ms2 ON m2.Title = ms2.Title
    JOIN Section s2 ON ms2.Section_ID = s2.Section_ID
    WHERE s2.Title = 'Желудочно-кишечные'
)
OR m.Title IN (
    SELECT m2.Title
    FROM Medicine m2
    JOIN Medicine_section ms2 ON m2.Title = ms2.Title
    JOIN Section s2 ON ms2.Section_ID = s2.Section_ID
    WHERE s2.Title = 'Противовирусные'
	INTERSECT
    SELECT m2.Title
    FROM Medicine m2
    JOIN Medicine_section ms2 ON m2.Title = ms2.Title
    JOIN Section s2 ON ms2.Section_ID = s2.Section_ID
    WHERE s2.Title = 'Антибиотики'
)
GROUP BY m.Title, m.Active_substance, m.Unit_price
ORDER BY 
    CASE 
        WHEN m.Active_substance = 'Дротаверин' THEN 1 
        WHEN m.Unit_price > 100 THEN 2               
        ELSE 3
    END

--6. Использование CASE, PIVOT и UNPIVOT
--CASE
--1)
SELECT [Ценовая категория], COUNT(Title) AS [Кол-во лекарства],
SUM(Unit_price) AS [Общая сумма]
FROM (
    SELECT Title, Unit_price,Quantity_in_pharmacy,
        CASE 
            WHEN Unit_price < 100 THEN 'Бюджетные'
            WHEN Unit_price BETWEEN 100 AND 200 THEN 'Средние'
            ELSE 'Выше среднего'
        END AS [Ценовая категория]
    FROM Medicine
) AS Price_category
GROUP BY [Ценовая категория]

--2)
SELECT [Активность клиента],  COUNT(ID) AS [Кол-во клиентов], AVG(Count_sale) AS [Среднее кол-во покупок],
SUM(Purchase_amount) AS [Общая сумма покупок], AVG(Purchase_amount) AS [Средний чек]
FROM (
    SELECT c.Client_ID AS ID, c.Full_name, COUNT(s.Sale_ID) AS Count_sale,
	SUM(ISNULL(s.Total_sum, 0)) AS Purchase_amount,
        CASE
            WHEN COUNT(s.Sale_ID) = 0 THEN 'Нет покупок'
            WHEN COUNT(s.Sale_ID) BETWEEN 0 AND 1 THEN 'Редкие покупки'
            ELSE '2 и более покупок'
        END AS [Активность клиента]
    FROM Client c
    LEFT JOIN Sale s ON c.Client_ID = s.Client_ID
    GROUP BY c.Client_ID, c.Full_name
) AS Client_activity
GROUP BY [Активность клиента]


--PIVOT
--1)
SELECT *
FROM (
    SELECT m.Manufacturer AS Производитель,s.Title AS Раздел, m.Title AS Лекарство,
	m.Quantity_in_pharmacy AS [Кол-во в аптеке]
    FROM Medicine m
    JOIN Medicine_section ms ON m.Title = ms.Title
    JOIN Section s ON ms.Section_ID = s.Section_ID
) AS medicine_table
PIVOT (
    COUNT(Лекарство)
    FOR Раздел IN ([Обезболивающие], [Жаропонижающие], [Желудочно-кишечные])
) AS pivot_table
ORDER BY Производитель
--2)
SELECT *
FROM (
    SELECT Cashier_last_name AS Кассир,Date_of_sale AS [Дата продажи],
    Total_sum AS Выручка
    FROM Sale
) AS sales_table
PIVOT (
    SUM(Выручка)
    FOR [Дата продажи] IN ([2025-09-20],[2025-09-21], [2025-09-22], [2025-09-23], [2025-09-24], [2025-09-30] )
) AS pivot_table
ORDER BY Кассир

--UNPIVOT
--3)
SELECT Лекарство, Характеристика, Значение
FROM (
    SELECT Title AS Лекарство, CAST(Unit_price AS NVARCHAR(50)) AS [Цена за ед.],
    CAST(Quantity_in_pharmacy AS NVARCHAR(50)) AS [Запасы в аптеке],
    CAST(Active_substance AS NVARCHAR(50)) AS [Действующее вещество],
    CAST(Manufacturer AS NVARCHAR(50)) AS Производитель
    FROM Medicine
    WHERE Title IN ('Глицин', 'Но-шпа')
) AS medicine_table
UNPIVOT (
    Значение FOR Характеристика IN ([Цена за ед.], [Запасы в аптеке], [Действующее вещество], Производитель)
) AS unpivot_table
--4)
SELECT Лекарство, Категория, Значение, [Кол-во продаж]
FROM (
    SELECT m.Title AS Лекарство,
        CAST(COUNT(sm.Sale_ID) AS NVARCHAR(50)) AS [Кол-во продаж],
        CAST(
		CASE
            WHEN m.Unit_price < 100 THEN 'Бюджетные'
            ELSE 'Дорогие'
        END AS NVARCHAR(50)) AS [Ценовая категория],
        CAST(
		CASE
            WHEN m.Quantity_in_pharmacy > 100 THEN 'Большой запас'
            ELSE 'Маленький запас'
        END AS NVARCHAR(50)) AS [Запасы],
        CAST(
		CASE
            WHEN m.Expiration_date > '2026-07-26' THEN 'Долгий срок'
            ELSE 'Короткий срок'
        END AS NVARCHAR(50)) AS [Срок годности]
    FROM Medicine m
    JOIN Sale_medicine sm ON m.Title = sm.Title
    GROUP BY m.Title, m.Unit_price, m.Quantity_in_pharmacy, m.Expiration_date
) AS price_table
UNPIVOT (
    [Значение] FOR [Категория] IN ([Ценовая категория], [Запасы], [Срок годности])
) AS unpivot_table
