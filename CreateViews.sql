CREATE VIEW ToppingPopularity AS
SELECT
    topping_TopName,
    SUM(pizza_topping_isDouble + 1) AS total_amount_used
FROM
    topping
JOIN
        pizza_topping ON topping.topping_TopID = pizza_topping.topping_TopID
GROUP BY
    topping_TopName
ORDER BY
    total_amount_used DESC;

CREATE VIEW ProfitByPizza AS
SELECT
    pizza_Size,
    pizza_CrustType,
    SUM(pizza_CustPrice - pizza_BusPrice) AS profit,
    DATE_FORMAT(ordertable_OrderDateTime,'%m/%Y') AS OrderMonth
FROM
    pizza
JOIN
    ordertable ON pizza.pizza_OrderID = ordertable.ordertable_OrderID
GROUP BY
    pizza_Size,
    pizza_CrustType,
    DATE_FORMAT(ordertable_OrderDateTime, '%m/%Y')
ORDER BY
    profit DESC;

CREATE VIEW ProfitByOrderType AS
SELECT
    o.ordertable_OrderType AS OrderType,
    DATE_FORMAT(o.ordertable_OrderDateTime, '%m/%Y') AS OrderMonth,
    SUM(o.ordertable_BusPrice) AS TotalOrderPrice,
    SUM(o.ordertable_CustPrice) AS TotalCustomerPrice,
    SUM(o.ordertable_CustPrice - o.ordertable_BusPrice) AS Profit
FROM
    ordertable o
GROUP BY
    OrderType, OrderMonth WITH ROLLUP
ORDER BY
    OrderType, OrderMonth;
