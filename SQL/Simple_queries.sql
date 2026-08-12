USE PharmacyDatabase
GO

--1. Найти всех производителей, чьи лекарства имеются на данный момент в аптеке
SELECT Manufacturer
FROM Medicine
WHERE Quantity_in_pharmacy > 0

--2.Вывести заболевания, для которых в аптеке нет лекарств
SELECT d.Disease_type, d.Disease_ID, md.Title
FROM Disease d LEFT JOIN Medicine_disease md
ON md.Disease_ID = d.Disease_ID
WHERE md.Title IS NULL 

--3.Найти самые дешевые лекарства с основным действующим веществом «дротаверин»
SELECT m.Title, m.Active_substance, m.Unit_price
FROM Medicine m 
WHERE m.Active_substance = 'дротаверин'
ORDER BY m.Unit_price ASC

--4.Найти все лекарства от ангины и насморка
SELECT md.Title,s.Symptoms_name, d.Disease_type
FROM Medicine_disease md 
LEFT JOIN Disease d ON md.Disease_ID = d.Disease_ID
LEFT JOIN Disease_symptoms ds ON d.Disease_ID = ds.Disease_ID
LEFT JOIN Symptom s ON ds.Symptoms_ID = s.Symptoms_ID
WHERE s.Symptoms_name = 'Насморк' OR d.Disease_type = 'Ангина'

--5.Для каждого лекарства вывести количество проданных с начала года упаковок с упорядочением кол-ва упаковок по убыванию
SELECT sm.Title AS Лекарство , SUM(sm.Medicine_count) AS Количество, YEAR(GETDATE()) AS Год_продажи
FROM Medicine m
LEFT JOIN Sale_Medicine sm ON m.Title = sm.Title
LEFT JOIN Sale s ON s.Sale_ID = sm.Sale_ID
WHERE YEAR(s.Date_of_sale) = YEAR(GETDATE())
GROUP BY sm.Title
ORDER BY SUM(sm.Medicine_count) DESC

--6.Выдать выручку аптеки за вчерашний день по каждому разделу лекарств
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
