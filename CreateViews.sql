CREATE VIEW ToppingPopularity AS
SELECT
    topping_TopName AS Topping,
    SUM(CASE WHEN pizza_topping_isDouble = 1 THEN 2 WHEN pizza_topping_isDouble IS NULL THEN 0 ELSE 1 END) AS ToppingCount
FROM
    topping
LEFT JOIN
        pizza_topping ON topping.topping_TopID = pizza_topping.topping_TopID
GROUP BY
    topping_TopName
ORDER BY
    `ToppingCount` DESC, topping_TopName ASC ;

CREATE VIEW ProfitByPizza AS
SELECT
    pizza_Size AS Size,
    pizza_CrustType AS Crust,
    SUM(pizza_CustPrice - pizza_BusPrice) AS Profit,
    DATE_FORMAT(ordertable_OrderDateTime,'%c/%Y') AS OrderMonth
FROM
    pizza
JOIN
    ordertable ON pizza.ordertable_OrderID = ordertable.ordertable_OrderID
GROUP BY
    pizza_Size,
    pizza_CrustType,
    DATE_FORMAT(ordertable_OrderDateTime, '%c/%Y')
ORDER BY
    profit;

CREATE VIEW ProfitByOrderType AS
    SELECT ordertable_OrderType AS customerType,
           CONCAT(MONTH(ordertable_OrderDateTime), '/', YEAR(ordertable_OrderDateTime)) AS OrderMonth,
           SUM(ordertable_CustPrice) AS TotalOrderPrice,
           SUM(ordertable_BusPrice) AS TotalOrderCost,
           SUM(ordertable_CustPrice - ordertable_BusPrice) AS Profit
    FROM ordertable
    GROUP BY `customerType`, `OrderMonth`
    UNION
    SELECT
        NULL,
        'Grand Total',
        SUM(ordertable_CustPrice),
        SUM(ordertable_BusPrice),
        SUM(ordertable_CustPrice - ordertable_BusPrice)
    FROM ordertable;


