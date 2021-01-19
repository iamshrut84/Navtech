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


CREATE PROCEDURE dbo.UpsertOrders

	@UpdateOrders dbo.OrdersTableType READONLY

AS
BEGIN


	BEGIN TRANSACTION UpsertOrders
	BEGIN TRY	
		MERGE Orders AS t
		Using @UpdateOrders AS s
		ON (t.OrderID = s.OrderID) 
		AND (t.OrderStatus = 1 or t.OrderStatus = 2) --Order update can happen only if status is 'Placed' or 'Approved'. 
		WHEN MATCHED THEN		--When matched, update the shippingAddress and OrderStatus details
		
		--Can only update the ordersStatus and ShippingAddress here. Cannot change the customerID and OrderID
		UPDATE  
		SET ShippingAddress = s.ShippingAddress,
		OrderStatus = s.OrderStatus,
		LastModified = GETDATE()		
			
		WHEN NOT MATCHED THEN --If not matched, add a new record into orders
				INSERT ([OrderID],[CustomerID],[OrderStatus],[ShippingAddress],[DateCreated],[LastModified]) VALUES(
				newid(), 
				s.CustomerID, 
				1, --OrderStatus = Placed
				s.ShippingAddress,
				GETDATE(),
				GETDATE()
				);

		COMMIT TRANSACTION UpsertOrders
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION UpsertOrders
			PRINT 'FAILURE on line ' + CONVERT(NVARCHAR(10), ERROR_LINE()) + ': ' + ERROR_MESSAGE()
		END CATCH


END







