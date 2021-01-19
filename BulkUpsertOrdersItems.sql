-- <fileName>BulkUpsert into Orders and OrderItems table</fileName>
-- <purpose>Stored Procedure to update a record in Orders and orderItems table if record exixts, else insert new one</purpose>
-- <author> Shruti Habbu </author>
-- <dateCreated>19-01-2021</dateCreated> 
-- <status> Ready for review </status> 
-- <reviewer>Navtech</reviewer>
-- <remarks> 


---***** -Note
--Assuming the SQL Statements calling these procedures will make use of BULK INSERT to insert the bulk orders from an input file like
-- .csv to the table type OrdersTableType

--CREATE TYPE OrdersTableType AS TABLE
--(
--	OrderID uniqueIdentifier NOT NULL,
--	OrderItemID uniqueIdentifier NOT NULL,
--	CustomerID uniqueIdentifier NOT NULL,
--	OrderStatus int,
--	ShippingAddress nvarchar(300),
--	ProductID uniqueIdentifier,
--	Quantity int,
--	DateCreated datetime
--);


CREATE PROCEDURE dbo.UpsertOrderItems

	@UpdateOrders dbo.OrdersTableType READONLY

AS
BEGIN
	BEGIN TRANSACTION UpsertOrderItems
	BEGIN TRY	
		MERGE OrderItems AS t
		Using @UpdateOrders AS s
		ON  (t.OrderID = s.OrderID) 
		AND (t.OrderItemID = s.OrderItemID)
		AND (Select orderStatus from Orders where orderID = t.orderID) in (1,2)
		WHEN MATCHED THEN		--When matched, update the product and quantity details
		--Can only update the ordersStatus and ShippingAddress here. Cannot change the customerID and OrderID
		UPDATE  
		SET ProductID = s.ProductID,
		Quantity = s.Quantity,
		LastModified = GETDATE()			
		WHEN NOT MATCHED THEN --If not matched, add a new record into orders
				INSERT ([OrderItemID],[OrderID],[ProductID],[Quantity],[LastModified],[DateCReated]) VALUES(
				newid(), 
				s.orderID,
				s.ProductID, 
				s.Quantity,
				GETDATE(),
				GETDATE()
				);

		COMMIT TRANSACTION UpsertOrderItems
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION UpsertOrderItems
			PRINT 'FAILURE on line ' + CONVERT(NVARCHAR(10), ERROR_LINE()) + ': ' + ERROR_MESSAGE()
		END CATCH
		
END
