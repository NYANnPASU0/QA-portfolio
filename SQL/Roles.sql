USE PharmacyDatabase;
GO

CREATE ROLE Director
CREATE ROLE Employee
GO
--таблицы
--директор
GRANT SELECT, UPDATE, DELETE ON dbo.Client TO Director WITH GRANT OPTION;
GRANT UNMASK ON dbo.Client TO Director;
GRANT SELECT, UPDATE, DELETE ON dbo.Orders TO Director WITH GRANT OPTION;
GRANT SELECT, UPDATE, DELETE ON dbo.Medicine TO Director WITH GRANT OPTION;
GRANT SELECT, UPDATE, DELETE ON dbo.Sale TO Director WITH GRANT OPTION;
GRANT SELECT, UPDATE, DELETE ON dbo.Disease TO Director WITH GRANT OPTION;
GRANT SELECT, UPDATE, DELETE ON dbo.Section TO Director WITH GRANT OPTION;
GRANT SELECT, UPDATE, DELETE ON dbo.Symptom TO Director WITH GRANT OPTION;
GRANT SELECT, UPDATE, DELETE ON dbo.Disease_symptoms TO Director WITH GRANT OPTION;
GRANT SELECT, UPDATE, DELETE ON dbo.Sale_medicine TO Director WITH GRANT OPTION;
GRANT SELECT, UPDATE, DELETE ON dbo.Medicine_disease TO Director WITH GRANT OPTION;
GRANT SELECT, UPDATE, DELETE ON dbo.Medicine_orders TO Director WITH GRANT OPTION;
GRANT SELECT, UPDATE, DELETE ON dbo.Medicine_section TO Director WITH GRANT OPTION;

--сотрудник
GRANT SELECT ON dbo.Medicine TO Employee;
GRANT SELECT ON dbo.Client TO Employee;
GRANT SELECT ON dbo.Orders TO Employee;
GRANT SELECT ON dbo.Section TO Employee
GRANT SELECT ON dbo.Medicine_section TO Employee;
GRANT SELECT ON dbo.Disease TO Employee;
GRANT SELECT ON dbo.Medicine_disease TO Employee;
GRANT SELECT ON dbo.Symptom TO Employee;
GRANT SELECT ON dbo.Disease_symptoms TO Employee;
GRANT SELECT, INSERT, UPDATE ON dbo.Sale TO Employee;
GRANT SELECT, INSERT, UPDATE ON dbo.Sale_medicine TO Employee;
GRANT UPDATE (Quantity_in_pharmacy) ON dbo.Medicine TO Employee;

DENY DELETE ON dbo.Medicine TO Employee; --revoke
DENY UNMASK ON dbo.Client TO Employee;

--представлени€
--директор
GRANT SELECT ON dbo.Cashiers_sale TO Director WITH GRANT OPTION;
GRANT SELECT ON dbo.Medicine_sale TO Director WITH GRANT OPTION;
--сотрудник
GRANT SELECT ON dbo.Masked_clients TO Employee;
DENY SELECT ON dbo.Cashiers_sale TO Employee;
DENY SELECT ON dbo.Medicine_sale TO Employee;

--процедуры и функции
--директор
GRANT EXECUTE ON dbo.Check_expiration_date TO Director WITH GRANT OPTION;
GRANT EXECUTE ON dbo.Check_cheapest_medicine TO Director WITH GRANT OPTION;
GRANT EXECUTE ON dbo.AVG_sales TO Director WITH GRANT OPTION;
GRANT EXECUTE ON dbo.Sales TO Director WITH GRANT OPTION;

GRANT SELECT ON dbo.Revenue TO Director WITH GRANT OPTION;
GRANT SELECT ON dbo.List_medicine TO Director WITH GRANT OPTION;
GRANT SELECT ON dbo.List_medicine_disease TO Director WITH GRANT OPTION;

--сотрудник
GRANT EXECUTE ON dbo.Check_expiration_date TO Employee;
GRANT EXECUTE ON dbo.Check_active_substance TO Employee;
GRANT EXECUTE ON dbo.Check_cheapest_medicine TO Employee;
GRANT EXECUTE ON dbo.List_medicine_disease TO Employee;


--создание пользователей
CREATE LOGIN User_Director WITH PASSWORD = '1234567';
CREATE LOGIN User1_Employee WITH PASSWORD = '1234567';

--DROP USER IF EXISTS User_Director;
--DROP USER IF EXISTS User1_Employee;
--GO

CREATE USER User_Director FOR LOGIN User_Director WITH DEFAULT_SCHEMA = dbo;
CREATE USER User1_Employee FOR LOGIN User1_Employee WITH DEFAULT_SCHEMA = dbo;
GO

ALTER ROLE Director ADD MEMBER User_Director;
ALTER ROLE Employee ADD MEMBER User1_Employee;
GO

-- ћаскирование
--1)

ALTER TABLE Client
ALTER COLUMN Phone_number ADD MASKED WITH (FUNCTION = 'partial(7,"***-**-",2)');

ALTER TABLE Client
ALTER COLUMN Adress ADD MASKED WITH (FUNCTION = 'partial(12,"*******",0)');

--2)
CREATE VIEW Masked_clients AS
SELECT Client_ID, Full_name, 
LEFT(Phone_number, 7) + '***-**-' + RIGHT(Phone_number, 2) AS Phone_number,
CASE
	WHEN CHARINDEX('г.', Adress) > 0 THEN LEFT(Adress, CHARINDEX(',', Adress) - 1) + '*******'
	ELSE Adress
END AS Adress
FROM dbo.Client
SELECT * FROM Masked_clients