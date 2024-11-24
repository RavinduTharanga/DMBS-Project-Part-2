USE PizzaDB;

-- Populate Toppings Table
INSERT INTO topping (topping_TopName, topping_SmallAMT, topping_MedAMT, topping_LgAMT, topping_XLAMT, topping_CustPrice, topping_BusPrice, topping_MinINVT, topping_CurINVT)
VALUES 
('Pepperoni', 2, 2.75, 3.5, 4.5, 1.25, 0.2, 50, 100),
('Sausage', 2.5, 3, 3.5, 4.25, 1.25, 0.15, 50, 100),
('Ham', 2, 2.5, 3.25, 4, 1.5, 0.15, 25, 78),
('Chicken', 1.5, 2, 2.25, 3, 1.75, 0.25, 25, 56),
('Green Pepper', 1, 1.5, 2, 2.5, 0.5, 0.02, 25, 79),
('Onion', 1, 1.5, 2, 2.75, 0.5, 0.02, 25, 85),
('Roma Tomato', 2, 3, 3.5, 4.5, 0.75, 0.03, 10, 86),
('Mushrooms', 1.5, 2, 2.5, 3, 0.75, 0.1, 50, 52),
('Black Olives', 0.75, 1, 1.5, 2, 0.6, 0.1, 25, 39),
('Pineapple', 1, 1.25, 1.75, 2, 1, 0.25, 0, 15),
('Jalapenos', 0.5, 0.75, 1.25, 1.75, 0.5, 0.05, 0, 64),
('Banana Peppers', 0.6, 1, 1.3, 1.75, 0.5, 0.05, 0, 36),
('Regular Cheese', 2, 3.5, 5, 7, 0.5, 0.12, 50, 250),
('Four Cheese Blend', 2, 3.5, 5, 7, 1, 0.15, 25, 150),
('Feta Cheese', 1.75, 3, 4, 5.5, 1.5, 0.18, 0, 75),
('Goat Cheese', 1.6, 2.75, 4, 5.5, 1.5, 0.2, 0, 54),
('Bacon', 1, 1.5, 2, 3, 1.5, 0.25, 0, 89);

-- Populate Discounts Table
INSERT INTO discount (discount_DiscountName, discount_Amount, discount_IsPercent)
VALUES 
('Employee', 15, 1), -- 15% discount
('Lunch Special Medium', 1, 0),
('Lunch Special Large', 2, 0),
('Specialty Pizza', 1.5, 0),
('Happy Hour', 10, 1), -- 10% discount
('Gameday Special', 20, 1); -- 20% discount

-- Populate Base Prices Table
INSERT INTO baseprice (baseprice_Size, baseprice_CrustType, baseprice_CustPrice, baseprice_BusPrice)
VALUES 
('Small', 'Thin', 3, 0.5),
('Small', 'Original', 3, 0.75),
('Small', 'Pan', 3.5, 1),
('Small', 'Gluten-Free', 4, 2),
('Medium', 'Thin', 5, 1),
('Medium', 'Original', 5, 1.5),
('Medium', 'Pan', 6, 2.25),
('Medium', 'Gluten-Free', 6.25, 3),
('Large', 'Thin', 8, 1.25),
('Large', 'Original', 8, 2),
('Large', 'Pan', 9, 3),
('Large', 'Gluten-Free', 9.5, 4),
('XLarge', 'Thin', 10, 2),
('XLarge', 'Original', 10, 3),
('XLarge', 'Pan', 11.5, 4.5),
('XLarge', 'Gluten-Free', 12.5, 6);

-- Add Customers
# INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum)
# VALUES
# ('John', 'Doe', '123-456-7890'),
# ('Jane', 'Smith', '987-654-3210'),
# ('Andrew', 'Wilkes-Krier', '864-254-5861'),
# ('Frank', 'Turner', '864-232-8944');
#
# -- Example Orders
# INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime, ordertable_CustPrice, ordertable_BusPrice, ordertable_isComplete)
# VALUES
# (1, 'dinein ', '2024-03-05 12:03:00', 19.75, 3.68, 1), -- Example completed dinein  order
# (2, 'pickup', '2024-04-03 12:05:00', 26.25, 4.63, 1), -- Example pickup order
# (3, 'delivery', '2024-04-20 19:11:00', 86.19, 23.62, 1), -- Example completed delivery order
# (4, 'delivery', '2024-03-02 17:30:00', 27.45, 7.88, 0); -- Example delivery in progress
#
# -- Example Pizzas
# INSERT INTO pizza (pizza_Size, pizza_CrustType, ordertable_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
# VALUES
# ('Large', 'Thin', 1, 'Completed', '2024-03-05 12:03:00', 19.75, 3.68),
# ('Medium', 'Pan', 2, 'Completed', '2024-04-03 12:05:00', 12.85, 3.23),
# ('XLarge', 'Gluten-Free', 3, 'Completed', '2024-04-20 19:11:00', 27.94, 9.19),
# ('XLarge', 'Thin', 4, 'In Progress', '2024-03-02 17:30:00', 27.45, 7.88);
#
# -- Populate Example Pizza Toppings
# INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
# VALUES
# (1, 1, 1), -- Double Pepperoni on pizza 1
# (1, 2, 0), -- Single Sausage on pizza 1
# (2, 5, 0), -- Single Green Pepper on pizza 2
# (2, 6, 0), -- Single Onion on pizza 2
# (3, 13, 1), -- Double Regular Cheese on pizza 3
# (4, 16, 0); -- Single Goat Cheese on pizza 4

CALL AddSingleOrderWithMultiplePizzas(
    NULL, NULL, NULL,                -- Customer Info (NULL for dine-in)
    'dinein',                        -- Order Type
    '2024-03-05 12:03:00',           -- Order DateTime
    NULL, NULL, NULL, NULL, NULL,    -- Delivery Address (not needed for dine-in)
    21,                              -- Table Number
    NULL,                            -- Is Picked Up (not needed for dine-in)
    1,                               -- Number of Pizzas
    'Large',                         -- Pizza Size
    'Thin',                          -- Pizza Crust
    'Regular Cheese:1,Pepperoni:0,Sausage:0',-- Pizza Toppings
    '19.75',                         -- Customer Price
    '3.68',                          -- Business Price
    'Lunch Special Large',           -- Pizza Discounts
    NULL,                            -- Order Discount
    1                                -- Is Complete
);


CALL AddSingleOrderWithMultiplePizzas(
    NULL, NULL, NULL,                -- Customer Info (NULL for dine-in)
    'dinein',                        -- Order Type
    '2024-04-03 12:05:00',           -- Order DateTime
    NULL, NULL, NULL, NULL, NULL,    -- Delivery Address (not needed for dine-in)
    4,                               -- Table Number
    NULL,                            -- Is Picked Up (not needed for dine-in)
    2,                               -- Number of Pizzas
    'Medium,Small',                  -- Pizza Sizes
    'Pan,Original',                  -- Pizza Crusts
    'Feta Cheese:0,Black Olives:0,Roma Tomato:0,Mushrooms:0,Banana Peppers:0|' -- Toppings for Pizza 1
    'Regular Cheese:0,Chicken:0,Banana Peppers:0',                                       -- Toppings for Pizza 2
    '12.85,6.93',                    -- Customer Prices
    '3.23,1.40',                     -- Business Prices
    'Lunch Special Medium,',         -- Pizza Discounts (discount for pizza 1 only)
    NULL,                            -- Order Discount
    1                                -- Is Complete
);

CALL AddSingleOrderWithMultiplePizzas(
    'Andrew', 'Wilkes-Krier', '864-254-5861', -- Customer Info
    'pickup',                                -- Order Type
    '2024-03-03 21:30:00',                   -- Order DateTime
    NULL, NULL, NULL, NULL, NULL,            -- Delivery Address (not needed for pickup)
    NULL,                                    -- Table Number
    0,                                       -- Is Picked Up
    6,                                       -- Number of Pizzas
    'Large,Large,Large,Large,Large,Large',   -- Pizza Sizes
    'Original,Original,Original,Original,Original,Original', -- Pizza Crusts
    'Regular Cheese:0,Pepperoni:0|Regular Cheese:0,Pepperoni:0|Regular Cheese:0,Pepperoni:0|Regular Cheese:0,Pepperoni:0|Regular Cheese:0,Pepperoni:0|Regular Cheese:0,Pepperoni:0',
    '14.88,14.88,14.88,14.88,14.88,14.88',   -- Customer Prices
    '3.30,3.30,3.30,3.30,3.30,3.30',         -- Business Prices
    NULL,                                    -- Pizza Discounts
    NULL,                                    -- Order Discount
    1                                        -- Is Complete
);


CALL AddSingleOrderWithMultiplePizzas(
    'Andrew', 'Wilkes-Krier', '864-254-5861', -- Customer Info
    'delivery',                              -- Order Type
    '2024-04-20 19:11:00',                   -- Order DateTime
    115, 'Party Blvd', 'Anderson', 'SC', 29621, -- Delivery Address
    NULL,                                    -- Table Number
    NULL,                                    -- Is Picked Up
    3,                                       -- Number of Pizzas
    'XLarge,XLarge,XLarge',                  -- Pizza Sizes
    'Original,Original,Original',            -- Pizza Crusts
    'Pepperoni:0,Sausage:0|Ham:1,Pineapple:1|Chicken:0,Bacon:0',
    '27.94,31.50,26.75',                     -- Customer Prices
    '9.19,6.25,8.18',                        -- Business Prices
    ',Specialty Pizza,',                     -- Pizza Discounts
    'Gameday Special',                       -- Order Discount
    1                                        -- Is Complete
);

-- Order 5: March 2nd - Pickup by Matt Engers
CALL AddSingleOrderWithMultiplePizzas(
    'Matt', 'Engers', '864-474-9953',      -- Customer Info
    'pickup',                             -- Order Type
    '2024-03-02 17:30:00',                -- Order DateTime
    NULL, NULL, NULL, NULL, NULL,         -- Delivery Address (not needed for pickup)
    NULL,                                 -- Table Number
    0,                                    -- Is Picked Up
    1,                                    -- Number of Pizzas
    'XLarge',                             -- Pizza Size
    'Gluten-Free',                        -- Pizza Crust
    'Green Pepper:0,Onion:0,Roma Tomato:0,Mushrooms:0,Black Olives:0,Goat Cheese:0',
    '27.45',                              -- Customer Price
    '7.88',                               -- Business Price
    'Specialty Pizza',                    -- Pizza Discount
    NULL,                                 -- Order Discount
    1                                     -- Is Complete
);

-- Order 6: March 2nd - Delivery by Frank Turner
CALL AddSingleOrderWithMultiplePizzas(
    'Frank', 'Turner', '864-232-8944',    -- Customer Info
    'delivery',                          -- Order Type
    '2024-03-02 18:17:00',               -- Order DateTime
    6745, 'Wessex St', 'Anderson', 'SC', 29621, -- Delivery Address
    NULL,                                -- Table Number
    NULL,                                -- Is Picked Up
    1,                                   -- Number of Pizzas
    'Large',                             -- Pizza Size
    'Thin',                              -- Pizza Crust
    'Chicken:0,Green Pepper:0,Onion:0,Mushrooms:0,Four Cheese Blend:1',
    '25.81',                             -- Customer Price
    '4.24',                              -- Business Price
    NULL,                                -- Pizza Discount
    NULL,                                -- Order Discount
    1                                    -- Is Complete
);

-- Order 7: April 13th - Delivery by Milo Auckerman
CALL AddSingleOrderWithMultiplePizzas(
    'Milo', 'Auckerman', '864-878-5679', -- Customer Info
    'delivery',                         -- Order Type
    '2024-04-13 20:32:00',              -- Order DateTime
    8879, 'Suburban Home', 'Anderson', 'SC', 29621, -- Delivery Address
    NULL,                               -- Table Number
    NULL,                               -- Is Picked Up
    2,                                  -- Number of Pizzas
    'Large,Large',                      -- Pizza Sizes
    'Thin,Thin',                        -- Pizza Crusts
    'Four Cheese Blend:1|Regular Cheese:0,Pepperoni:1', -- Toppings for each pizza
    '18.00,19.25',                      -- Customer Prices
    '2.75,3.25',                        -- Business Prices
    NULL,                               -- Pizza Discounts
    'Employee Discount',                -- Order Discount
    1                                   -- Is Complete
);