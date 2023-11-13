/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select StockItemID, StockItemName from Warehouse.StockItems
where StockItemName like '%urgent%' or StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select s.SupplierID, s.SupplierName from Purchasing.Suppliers as s
	left join Purchasing.PurchaseOrders as po on po.SupplierID = s.SupplierID
where po.PurchaseOrderID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
select o.OrderID
		, convert(varchar, o.OrderDate, 104) as [DD.MM.YYYY]
		, datename(month, o.OrderDate) as [Month]
		, datepart(QUARTER, o.OrderDate) as [Quarter]
		, [Third] = case when month(o.OrderDate) in(1, 2, 3, 4) then 1							when month(o.OrderDate) in(5, 6, 7, 8) then 2							when month(o.OrderDate) in(9, 10, 11, 12) then 3 							end
		, c.CustomerName 
from Sales.Orders as o
	join Sales.OrderLines as ol on ol.OrderID = o.OrderID
	join Sales.Customers as c on c.CustomerID = o.CustomerID
where ol.UnitPrice > 100 or (ol.Quantity > 20 and ol.PickingCompletedWhen is not null)
order by [Quarter], [Third], [DD.MM.YYYY]

select o.OrderID
		, convert(varchar, o.OrderDate, 104) as [DD.MM.YYYY]
		, datename(month, o.OrderDate) as [Month]
		, datepart(QUARTER, o.OrderDate) as [Quarter]
		, [Third] = case when month(o.OrderDate) in(1, 2, 3, 4) then 1							when month(o.OrderDate) in(5, 6, 7, 8) then 2							when month(o.OrderDate) in(9, 10, 11, 12) then 3 							end
		, c.CustomerName 
from Sales.Orders as o
	join Sales.OrderLines as ol on ol.OrderID = o.OrderID
	join Sales.Customers as c on c.CustomerID = o.CustomerID
where ol.UnitPrice > 100 or (ol.Quantity > 20 and ol.PickingCompletedWhen is not null)
order by [Quarter], [Third], [DD.MM.YYYY]
offset 1000 ROWS FETCH NEXT 100 ROWS ONLY

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.DeliveryMethods.
*/
select dm.DeliveryMethodName
		, po.ExpectedDeliveryDate
		, s.SupplierName
		, p.FullName
from Purchasing.Suppliers as s
	join Purchasing.PurchaseOrders as po on po.SupplierID = s.SupplierID
	join [Application].DeliveryMethods as dm on dm.DeliveryMethodID = s.DeliveryMethodID
	join [Application].People as p on p.PersonID = po.ContactPersonID
where po.ExpectedDeliveryDate between '20130101' and '20130131'
	and dm.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight')
	and po.IsOrderFinalized = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top 10 with ties o.OrderID
		, c.CustomerName
		, p.FullName
		, o.OrderDate
from [Sales].[Orders] as o
	join [Sales].[Customers] as c on c.CustomerID = o.SalespersonPersonID
	join [Application].[People] as p on p.PersonID = o.CustomerID
order by o.OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/
select p.PersonID
		, p.FullName
		, p.PhoneNumber
from [Purchasing].[PurchaseOrders] as po
	left join [Purchasing].[PurchaseOrderLines] as pol on pol.PurchaseOrderID = po.PurchaseOrderID --where pol.StockItemID = 224
	join [Application].[People] as p on p.PersonID = po.ContactPersonID
	join [Warehouse].[StockItems] as si on si.StockItemID = pol.StockItemID
	where si.StockItemName = 'Chocolate frogs 250g'

