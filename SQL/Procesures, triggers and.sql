USE PharmacyDatabase;
GO


--Лабораторная работа 4

--Хранимые процедуры

--a) Процедура без параметров, формирующая список лекарств, для которых срок годности заканчивается меньше, чем через 1 месяц

--DROP PROCEDURE Check_expiration_date;

CREATE PROCEDURE Check_expiration_date
AS
BEGIN
	SELECT *
	FROM Medicine
	WHERE DATEADD(MONTH, 1, GETDATE()) > Expiration_date
END;
GO
EXECUTE Check_expiration_date
GO



--b) Процедура, на входе получающая название основного действующего вещества и формирующая список лекарств
--с этим действующим веществом, упорядоченный по возрастанию цены в виде: название лекарства, цена, производитель

--DROP PROCEDURE Check_active_substance;
CREATE PROCEDURE Check_active_substance @Active_substance NVARCHAR(20)
AS
BEGIN
	SELECT Title AS [Название лекарства], Unit_price AS Цена, Manufacturer AS Производитель
	FROM Medicine
	WHERE @Active_substance = Active_substance
	ORDER BY Unit_price ASC
END;

EXECUTE Check_active_substance Дротаверин
GO


--c) Процедура, на входе получающая название лекарства, выходной параметр – самый дешевый его аналог с тем же действующим веществом

--DROP PROCEDURE Check_cheapest_medicine;
CREATE PROCEDURE Check_cheapest_medicine @Medicine_Title NVARCHAR(20), @Cheapest_medicine NVARCHAR(20) OUTPUT
AS
BEGIN
	DECLARE @Active_substance NVARCHAR(20)
	SET @Active_substance = (
		SELECT Active_substance
		FROM Medicine
		WHERE @Medicine_Title = Title )
	SET @Cheapest_medicine = (
		SELECT TOP 1 Title
		FROM Medicine
		WHERE @Active_substance = Active_substance 
		ORDER BY Unit_price ASC)
	IF @Cheapest_medicine = @Medicine_Title
	BEGIN
		SET @Cheapest_medicine = 'Аналогов нет'
	END
END;
DECLARE @Cheapest_medicine_t NVARCHAR(20)
EXECUTE Check_cheapest_medicine 'Фенистил', @Cheapest_medicine_t OUTPUT
--EXECUTE Check_cheapest_medicine 'Спазмалгон', @Cheapest_medicine_t OUTPUT
PRINT @Cheapest_medicine_t
--SELECT @Cheapest_medicine_t AS 'Аналог'
GO



--d) Процедура, вызывающая вложенную процедуру, которая подсчитывает среднее количество наименований лекарств для одной продажи,
--а сама выводит продажи с количеством лекарств, превышающим среднее в виде: номер продажи, дата, сумма, кассир
--DROP PROCEDURE AVG_sales;
CREATE PROCEDURE AVG_sales @AVG_medicine INT OUTPUT
AS
BEGIN
	SET @AVG_medicine = (
		SELECT AVG(Med_title)
		FROM (
			SELECT Sale_ID, COUNT(DISTINCT Title) AS Med_title
			FROM Sale_medicine
			GROUP BY Sale_ID) AS s )
END;
GO

--DROP  PROCEDURE Sales
CREATE PROCEDURE Sales 
AS
BEGIN
	DECLARE @AVG_counts INT
	EXECUTE AVG_sales @AVG_medicine = @AVG_counts OUTPUT
	SELECT s.Sale_ID, Date_of_sale, Total_sum, Cashier_last_name
	FROM Sale s
	WHERE s.Sale_ID IN (
        SELECT Sale_ID
        FROM Sale_medicine
        GROUP BY Sale_ID
        HAVING SUM(Medicine_count) > @AVG_counts)

END;
EXECUTE Sales 



--Пользовательские функции

--a) Скалярная функция, возвращающая выручку аптеки на заданную дату

--DROP FUNCTION dbo.Revenue
CREATE FUNCTION dbo.Revenue(@Date DATE)
RETURNS MONEY
AS
BEGIN
	DECLARE @revenue MONEY
	SET @revenue = (
		SELECT SUM(Total_sum)
		FROM Sale
		WHERE Date_of_sale = @Date )
	RETURN @revenue
END;
PRINT dbo.Revenue ('2025-09-23')

--b) Inline-функция, возвращающая список лекарств и их количество, проданных на заданную дату
--DROP FUNCTION dbo.List_medicine
CREATE FUNCTION dbo.List_medicine(@Date DATE) 
RETURNS TABLE
AS
RETURN
(
	SELECT DISTINCT Title AS Лекарство, SUM(Medicine_count) AS Продано
	FROM Sale_medicine sm
	JOIN Sale s ON s.Sale_ID = sm.Sale_ID
	WHERE Date_of_sale = @Date
	GROUP BY Title
)

SELECT * FROM dbo.List_medicine('2025-09-21')



--с) Multi-statement-функция, выдающая список лекарств от заданной болезни, имеющихся в аптеке с указанием количества упаковок

--DROP FUNCTION dbo.List_medicine_disease
CREATE FUNCTION dbo.List_medicine_disease(@Disease NVARCHAR(20)) 
RETURNS @return_list TABLE
(
	Title NVARCHAR(20),
	Quantity_in_pharmacy INT
)
AS
BEGIN
	INSERT INTO @return_list
	SELECT m.Title, Quantity_in_pharmacy
	FROM Medicine m
	JOIN Medicine_disease md ON m.Title = md.Title
	JOIN Disease d ON d.Disease_ID = md.Disease_ID
	WHERE d.Disease_type = @Disease
	GROUP BY m.Title, Quantity_in_pharmacy

	RETURN
END;

SELECT * FROM dbo.List_medicine_disease('Гастрит')



--Триггеры 

--a) Триггер любого типа на добавление лекарства в заказ: при добавлении нового лекарства проверить,
--сформирован ли уже заказ на сегодня, если нет, то создать новый заказ на текущую дату и добавить туда лекарство.
--Если на сегодня заказ есть, то лекарство добавляется к нему

--DROP TRIGGER add_to_medicine_order

CREATE TRIGGER add_to_medicine_order
ON Medicine_orders
INSTEAD OF INSERT
AS
BEGIN
    IF NOT EXISTS(
        SELECT *
        FROM Orders
        WHERE Order_date = CAST(GETDATE() AS DATE)
    )
    BEGIN
        DECLARE @all_amount MONEY
        SELECT @all_amount = ISNULL(SUM(m.Unit_price), 0)
        FROM inserted i
        JOIN Medicine m ON i.Title = m.Title

        INSERT INTO Orders(Amount, Order_date)
        VALUES (@all_amount, CAST(GETDATE() AS DATE))

		DECLARE @latest_id INT
        SET @latest_id = ISNULL((SELECT MAX(Order_ID) FROM Orders), 0)
        
        INSERT INTO Medicine_orders(Title, Order_ID)
        SELECT Title, @latest_id FROM inserted
    END
    ELSE
    BEGIN
        DECLARE @latest_exist_id INT
        DECLARE @new_amount MONEY

        SET @latest_exist_id = (
            SELECT TOP 1 Order_ID
            FROM Orders
            WHERE Order_date = CAST(GETDATE() AS DATE) 
            ORDER BY Order_ID DESC
        )

        SELECT @new_amount = ISNULL(SUM(m.Unit_price), 0)
        FROM inserted i
        JOIN Medicine m ON i.Title = m.Title

        UPDATE Orders 
        SET Amount = Amount + @new_amount
        WHERE Order_ID = @latest_exist_id

        INSERT INTO Medicine_orders(Title, Order_ID)
        SELECT Title, @latest_exist_id FROM inserted
    END
END;

INSERT INTO Medicine_orders(Title)
VALUES ('Активированный уголь'),('Фенистил')
INSERT INTO Medicine_orders(Title)
VALUES ('Омепразол')
INSERT INTO Medicine_orders(Title)
VALUES ('Активированный уголь'),('Но-шпа')


--b) Последующий триггер на изменение количества лекарства в аптеке – если количество упаковок лекарства < 3,
--формируем строку с заказом на это лекарство

--DROP TRIGGER update_order

CREATE TRIGGER update_order
ON Medicine
AFTER UPDATE
AS
BEGIN
	IF EXISTS(SELECT 1 FROM inserted WHERE Quantity_in_pharmacy < 3)
	BEGIN
		INSERT INTO Medicine_orders(Title)
		SELECT Title
        FROM inserted 
        WHERE Quantity_in_pharmacy < 3
	END
END;

UPDATE Medicine
SET Quantity_in_pharmacy = 2
WHERE Title = 'Називин'

UPDATE Medicine
SET Quantity_in_pharmacy = 2
WHERE Title = 'Аспирин'

UPDATE Medicine
SET Quantity_in_pharmacy = 2
WHERE Title = 'Омепразол'


--c) Замещающий триггер на операцию удаления лекарства из списка купленных покупателем лекарств –
--если покупатель передумал покупать только что купленное лекарство, то выполняем операцию возврата
--(удаляем это лекарство из списка купленных этим покупателем лекарств, возвращаем его в аптеку, пересчитываем сумму чека для покупателя).

--DROP TRIGGER del_medicine
CREATE TRIGGER del_medicine
ON Sale_medicine
INSTEAD OF DELETE
AS
BEGIN
	DELETE sm
	FROM Sale_medicine sm
	JOIN deleted d ON sm.Title = d.Title AND sm.Sale_ID = d.Sale_ID

	UPDATE m
	SET m.Quantity_in_pharmacy = m.Quantity_in_pharmacy + d.Medicine_count
	FROM Medicine m
	JOIN deleted d ON d.Title = m.Title

	UPDATE s
    SET Total_sum = 
        CASE 
            WHEN (Total_sum - sums.amount_to_deduct ) > 0 
            THEN Total_sum - sums.amount_to_deduct  
            ELSE 0
        END
    FROM Sale s
    JOIN ( SELECT d.Sale_ID,
           SUM(m.Unit_price * d.Medicine_count) as amount_to_deduct 
           FROM Medicine m 
           JOIN deleted d ON m.Title = d.Title
           GROUP BY d.Sale_ID
         ) sums ON s.Sale_ID = sums.Sale_ID

	DELETE FROM Sale 
    WHERE Total_sum = 0

END;


DELETE FROM Sale_medicine
WHERE Title = 'Активированный уголь' AND Sale_ID = 10
DELETE FROM Sale_medicine
WHERE Title IN ('Називин', 'Но-шпа')
  AND Sale_ID IN (6, 8)
DELETE FROM Sale_medicine
WHERE Title = 'Фенистил'

DELETE FROM Sale_medicine
WHERE Title = 'Аспирин' AND Sale_ID = 3








--DISABLE TRIGGER add_to_medicine_order ON Medicine_orders
--DBCC CHECKIDENT ('Orders', RESEED, 11)
--ENABLE TRIGGER add_to_medicine_order ON Medicine_orders