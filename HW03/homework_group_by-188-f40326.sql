/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select 
	year(i.InvoiceDate) as YearOfDate
	, month(i.InvoiceDate) as MonthOfDate
	, avg(il.UnitPrice) as AvgUnitPrice
	, sum(il.ExtendedPrice) as SumExtendedPrice
from [Sales].[Invoices] as i
	left join [Sales].[InvoiceLines] as il on il.InvoiceID = i.InvoiceID
group by year(i.InvoiceDate), month(i.InvoiceDate)

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select 
	year(i.InvoiceDate) as YearOfDate
	, month(i.InvoiceDate) as MonthOfDate
	, sum(il.ExtendedPrice) as SumExtendedPrice
from [Sales].[Invoices] as i
	left join [Sales].[InvoiceLines] as il on il.InvoiceID = i.InvoiceID
group by year(i.InvoiceDate), month(i.InvoiceDate)
having sum(il.ExtendedPrice) > 4600000

select 
	year(i.InvoiceDate) as YearOfDate
	, month(i.InvoiceDate) as MonthOfDate
	, isnull(sum(il.ExtendedPrice), 0) as SumExtendedPrice
from [Sales].[Invoices] as i
	left join [Sales].[InvoiceLines] as il on il.InvoiceID = i.InvoiceID
group by year(i.InvoiceDate), month(i.InvoiceDate)
having isnull(sum(il.ExtendedPrice), 0) > 4600000

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select 
	year(i.InvoiceDate) as YearOfDate
	, month(i.InvoiceDate) as MonthOfDate
	, si.StockItemName
	, sum(il.ExtendedPrice) as SumExtendedPrice
	, min(i.InvoiceDate) as FirstSale
	, sum(il.Quantity) as CountSale
from [Sales].[Invoices] as i
	left join [Sales].[InvoiceLines] as il on il.InvoiceID = i.InvoiceID
	join [Sales].[OrderLines] as ol on ol.OrderID = i.OrderID
	join [Warehouse].[StockItems] as si on si.StockItemID = ol.StockItemID
group by year(i.InvoiceDate), month(i.InvoiceDate), si.StockItemName
having sum(il.Quantity) < 50

select 
	year(i.InvoiceDate) as YearOfDate
	, month(i.InvoiceDate) as MonthOfDate
	, si.StockItemName
	, isnull(sum(il.ExtendedPrice), 0) as SumExtendedPrice
	, min(i.InvoiceDate) as FirstSale
	, sum(il.Quantity) as CountSale
from [Sales].[Invoices] as i
	left join [Sales].[InvoiceLines] as il on il.InvoiceID = i.InvoiceID
	join [Sales].[OrderLines] as ol on ol.OrderID = i.OrderID
	join [Warehouse].[StockItems] as si on si.StockItemID = ol.StockItemID
group by year(i.InvoiceDate), month(i.InvoiceDate), si.StockItemName
having sum(il.Quantity) < 50

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
