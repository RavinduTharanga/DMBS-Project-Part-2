CREATE VIEW ToppingPopularity AS
SELECT
    topping_TopName AS Topping,
    SUM(pizza_topping_isDouble + 1) AS ToppingCount
FROM
    topping
JOIN
        pizza_topping ON topping.topping_TopID = pizza_topping.topping_TopID
GROUP BY
    topping_TopName
ORDER BY
    SUM(pizza_topping_isDouble + 1) DESC;

CREATE VIEW ProfitByPizza AS
SELECT
    pizza_Size AS Size,
    pizza_CrustType AS Crust,
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
    profit;

CREATE VIEW ProfitByOrderType AS
SELECT
    IFNULL(o.ordertable_OrderType, 'Grand Total') AS customerType,
    IFNULL(DATE_FORMAT(MAX(o.ordertable_OrderDateTime), '%m/%Y'), 'Grand Total') AS OrderMonth,
    SUM(o.ordertable_CustPrice - o.ordertable_BusPrice) AS Profit,
    SUM(o.ordertable_BusPrice) AS TotalOrderPrice,
    SUM(o.ordertable_CustPrice) AS TotalOrderCost
FROM
    ordertable o
GROUP BY
    o.ordertable_OrderType, DATE_FORMAT(o.ordertable_OrderDateTime, '%m/%Y') WITH ROLLUP
ORDER BY
    o.ordertable_OrderType,
    -- Sort by OrderMonth, ensuring that 'Grand Total' is sorted last
    IFNULL(DATE_FORMAT(MAX(o.ordertable_OrderDateTime), '%m/%Y'), 'Grand Total') = 'Grand Total',
    DATE_FORMAT(MAX(o.ordertable_OrderDateTime), '%m/%Y');
