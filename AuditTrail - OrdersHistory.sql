/*
We can achieve audit trail of changes made to tables, we can use methods like Change Tracking, Change Data Capture (CDC), Temporal tables
or Triggers. Here, I have considered writing triggers for implementing change tracking of the orders table. 

Whenever a record is inserted or updated to the table Orders, the changes made will be recorded in the tblOrdersAudit table. 
*/

CREATE TABLE tblOrdersAudit
(
  OrderAuditID integer Identity(1,1) primary key,
  OrderID uniqueidentifier,
  CustomerID uniqueidentifier,
  ShippingAddress nvarchar(300),
  OrderStatus varchar(20),
  UpdatedBy nvarchar(128),
  UpdatedOn datetime
)
go


CREATE TRIGGER tblTriggerAuditRecord on Navtech.dbo.Orders
AFTER UPDATE, INSERT
AS
BEGIN
  INSERT INTO tblOrdersAudit 
  (OrderID, CustomerID,ShippingAddress, OrderStatus, UpdatedBy, UpdatedOn )
  select i.OrderID, i.CustomerID, i.ShippingAddress, i.OrderStatus, SUSER_SNAME(), getdate() 
  from  Orders o 
  inner join inserted i on o.OrderID=i.OrderID 
END
GO


