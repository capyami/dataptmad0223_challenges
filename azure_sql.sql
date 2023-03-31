-- Challenge azure

-- Query

-- Inner Join
SELECT *
FROM Customers INNER JOIN Invoices ON Customers.ID = Invoices.Customer

-- Full join
SELECT *
FROM Customers FULL JOIN Invoices ON Customers.ID = Invoices.Customer

-- Left join
SELECT *
FROM Customers LEFT JOIN Invoices ON Customers.ID = Invoices.Customer
    
-- Right join
SELECT *
FROM Customers RIGHT JOIN Invoices ON Customers.ID = Invoices.Customer

-- Exclusive left join
SELECT *
FROM Customers LEFT JOIN Invoices ON Customers.ID = Invoices.Customer
WHERE Invoices.Customer IS NULL

-- Exclusive right join
SELECT *
FROM Customers RIGHT JOIN Invoices ON Customers.ID = Invoices.Customer
WHERE Customers.ID IS NULL

-- Exclusive full join
SELECT *
FROM Customers FULL JOIN Invoices ON Customers.ID = Invoices.Customer
WHERE Customers.ID IS NULL OR Invoices.Customer IS NULL

-- Cross join
SELECT *
FROM Customers CROSS JOIN Invoices


SELECT c.FirstNAme + ' ' + c.LastName AS [Customer Fullname], p.Name AS [Product Name]
FROM SalesLT.Customer AS c
    INNER JOIN SalesLT.SalesOrderHeader AS soh on c.CustomerID = soh.CustomerID
    INNER JOIN SalesLT.SalesOrderDetail AS shd ON soh.SalesOrderID = shd.SalesOrderID
    INNER JOIN SalesLT.Product AS p ON shd.ProductID = p.ProductID
ORDER BY [Customer Fullname], [Product Name]

-- Descripción de productos en árabe
SELECT  pm.Name AS 'Product Model', pd.[Description]
FROM SalesLT.ProductModel AS pm    
    INNER JOIN SalesLT.ProductModelProductDescription AS pmpd ON pm.ProductModelID = pmpd.ProductModelID
    INNER JOIN SalesLT.ProductDescription AS pd on PD.ProductDescriptionID = pmpd.ProductDescriptionID
    INNER JOIN SalesLT.Product AS p ON p.ProductModelID = pm.ProductModelID
WHERE pmpd.Culture = 'ar' AND p.ProductID = 710;

-- Primero hay que hablar con negocio para definir correctamente qué es una venta: ¿un conteo? ¿nº de unidades vendidas? 
SELECT   p.name
    , COUNT(*) AS 'Total Orders' -- en este caso es un simple conteo de los registros
FROM SalesLT.Product AS p
    INNER JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY  p.Name
ORDER BY 'Total Orders' DESC

-- ventas por producto
SELECT p.Name As [Product], COUNT(*) AS [Total] – aunque más correcto sería hacer COUNT(DISTINCT soh.SalesOrderID)
FROM SalesLT.SalesOrderHeader AS soh 
    INNER JOIN SalesLT.SalesOrderDetail AS shd ON soh.SalesOrderID = shd.SalesOrderID
    INNER JOIN SalesLT.Product AS p ON shd.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY 2 DESC

-- ventas por categoría y producto
SELECT  pc.Name AS [Category], p.name AS Product, SUM(sod.OrderQty) AS [Total Qty]
FROM SalesLT.Product AS p
    INNER JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
    INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY  pc.Name, p.Name
ORDER BY 1, 2 

-- ventas por categoría, y categoría-producto
SELECT pc.Name AS [Category],  p.Name As [Product], SUM(shd.OrderQty) AS [Total Qty]
FROM SalesLT.SalesOrderHeader AS soh 
    INNER JOIN SalesLT.SalesOrderDetail AS shd ON soh.SalesOrderID = shd.SalesOrderID
    INNER JOIN SalesLT.Product AS p ON shd.ProductID = p.ProductID
    INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY GROUPING SETS ((pc.Name), (pc.Name, p.Name))
ORDER BY 1, 2 

-- ventas mayores de ocho por categoría, y categoría-producto
SELECT pc.Name AS [Category],  p.Name As [Product], SUM(shd.OrderQty) AS [Total Qty]
FROM SalesLT.SalesOrderHeader AS soh 
    INNER JOIN SalesLT.SalesOrderDetail AS shd ON soh.SalesOrderID = shd.SalesOrderID
    INNER JOIN SalesLT.Product AS p ON shd.ProductID = p.ProductID
    INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY GROUPING SETS ((pc.Name), (pc.Name, p.Name))
HAVING COUNT(DISTINCT soh.SalesOrderID) >= 8

-- ejemplos de funciones de ventana
SELECT p.ProductID, pc.Name AS 'Category', p.Name AS 'Product', p.[Size]

    -- ranking
    , ROW_NUMBER() OVER (PARTITION BY p.ProductCategoryID ORDER BY p.Size) AS 'Row Number Per Category & Size'
    , RANK() OVER (PARTITION BY p.ProductCategoryID ORDER BY p.Size) AS 'Rank Per Category & Size'
    , DENSE_RANK() OVER (PARTITION BY p.ProductCategoryID ORDER BY p.Size) AS 'Dense Rank Per Category & Size'
    , NTILE(2) OVER (PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'NTile Per Category & Name'

    -- aggregate
    , SUM(p.StandardCost) OVER() AS 'Standard Cost Grand Total'
    , SUM(p.StandardCost) OVER(PARTITION BY p.ProductCategoryID) AS 'Standard Cost Per Category'
    
    -- analytical
    , LAG(p.Name, 1, '-- NOT FOUND --') OVER(PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'Previous Product Per Category'
    , LEAD(p.Name, 1, '-- NOT FOUND --') OVER(PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'Next Product Per Category'
    , FIRST_VALUE(p.Name) OVER(PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'First Product Per Category'
    , LAST_VALUE(p.Name) OVER(PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'Last Product Per Category'
FROM SalesLT.Product AS p
    INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
ORDER BY pc.Name, p.Name 


CREATE OR ALTER PROCEDURE [SalesLT].[uspUpdateCustomerAddress]
    @CustomerID INT, 
    @AddressType NVARCHAR(50), 
    @AddressLine NVARCHAR(50), 
    @City NVARCHAR(50), 
    @StateProvince NVARCHAR(50), 
    @CountryRegion NVARCHAR(50),  
    @PostalCode NVARCHAR(50)
WITH EXECUTE AS CALLER
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
    
    
        --  Comprobamos que el cliente referenciado existe. En caso contrario se devuelve mensaje de error 
        -- y finaliza la ejecución del procedimiento
        IF NOT EXISTS (SELECT 1 FROM SalesLT.Customer WHERE CustomerID = @CustomerID)
        BEGIN
            RAISERROR(N'Customer doesn''t exist', 16, 127) WITH NOWAIT;
            RETURN;
        END
    
        --  Iniciamos transacción para ejecutar todas las instrucciones como si fuera una sola
        BEGIN TRANSACTION;
        
        DECLARE @newAddress INT;
        
        --  Insertamos un nuevo registro
        INSERT INTO SalesLT.Address (AddressLine1, City, StateProvince, CountryRegion, PostalCode)
        VALUES (@AddressLine, @City, @StateProvince, @CountryRegion, @PostalCode)

        --  Recogemos el valor del identificador autogenerado;
        SELECT @newAddress = SCOPE_IDENTITY() ;

        --  Almacenamos la nueva relación entre Cliente y su dirección
        INSERT INTO SalesLT.CustomerAddress (CustomerID, AddressID, AddressType)            
        VALUES (@CustomerID, @newAddress, @AddressType);

        --  Confirmamos transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        --  Cancelamos transacción en caso de que haya habido algún error       
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        DECLARE  @ErrorMessage  NVARCHAR(4000),  @ErrorSeverity INT,  @ErrorState    INT;
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(), 
            @ErrorSeverity = ERROR_SEVERITY(), 
            @ErrorState = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        
    END CATCH;
    

END;





--  Mostramos la dirección de un cliente aleatorio
SELECT TOP 1 c.CustomerID, c.FirstName, c.LastName, a.AddressID, ca.AddressType, a.AddressLine1, a.City, a.StateProvince, a.CountryRegion, a.PostalCode
FROM SalesLT.Customer AS c
    INNER JOIN SalesLT.CustomerAddress AS ca ON c.CustomerID = ca.CustomerID
    INNER JOIN SalesLT.Address AS a ON ca.AddressID = a.AddressID
WHERE c.CustomerID = 29485
ORDER BY a.ModifiedDate DESC;

--  La modificamos
EXEC [SalesLT].[uspUpdateCustomerAddress]
    @CustomerID = 29485, 
    @AddressType = 'HOME', 
    @AddressLine = 'Nueva dirección', 
    @City ='Nueva ciudad', 
    @StateProvince = ' Nuevo Estado', 
    @CountryRegion = 'Nueva Región',  
    @PostalCode = '00000';

--  Mostramos la última dirección asignada del mismo cliente
SELECT TOP 1 c.CustomerID, c.FirstName, c.LastName, a.AddressID, ca.AddressType, a.AddressLine1, a.City, a.StateProvince, a.CountryRegion, a.PostalCode
FROM SalesLT.Customer AS c
    INNER JOIN SalesLT.CustomerAddress AS ca ON c.CustomerID = ca.CustomerID
    INNER JOIN SalesLT.Address AS a ON ca.AddressID = a.AddressID
WHERE c.CustomerID = 29485
ORDER BY a.ModifiedDate DESC;

