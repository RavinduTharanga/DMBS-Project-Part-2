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
('Employee', 1.5, 0), -- 15% discount
('Lunch Special Medium', 1, 0),
('Lunch Special Large', 2, 0),
('Specialty Pizza', 2, 0),
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
# (1, 'dine-in', '2024-03-05 12:03:00', 19.75, 3.68, 1), -- Example completed dine-in order
# (2, 'pickup', '2024-04-03 12:05:00', 26.25, 4.63, 1), -- Example pickup order
# (3, 'delivery', '2024-04-20 19:11:00', 86.19, 23.62, 1), -- Example completed delivery order
# (4, 'delivery', '2024-03-02 17:30:00', 27.45, 7.88, 0); -- Example delivery in progress
#
# -- Example Pizzas
# INSERT INTO pizza (pizza_Size, pizza_CrustType, pizza_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
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
    NULL, NULL, NULL,           -- No customer details for dine-in
    'dine-in',
    '2024-03-05 12:03:00',
    19.75,
    3.68,
    1,
    NULL, NULL, NULL, NULL, NULL, -- No delivery address
    21,                           -- Table number for dine-in
    NULL,                         -- Not a pickup
    'Large,', 'Thin',
    '19.75', '3.68',
    'Regular Cheese,Pepperoni,Sausage',
    'Lunch Special Large',
    NULL-- Discount applied
);

CALL AddSingleOrderWithMultiplePizzas(
    NULL, NULL, NULL,           -- No customer details for dine-in
    'dine-in',
    '2024-04-03 12:05:00',
    19.78,
    4.63,
    1,
    NULL, NULL, NULL, NULL, NULL, -- No delivery address
    4,                            -- Table number for dine-in
    NULL,                         -- Not a pickup
    'Medium,Small,', 'Pan,Original',
    '12.85,6.93', '3.23,1.40',
    'Feta Cheese,Black Olives,Roma Tomatoes,Mushrooms,Banana Peppers;Regular Cheese,Chicken,Banana Peppers',
    'Lunch Special Medium,NULL',        -- Discount applied
     'Specialty Pizza,NULL'
);

# CALL AddSingleOrderWithMultiplePizzas(
#     NULL, NULL, NULL,           -- No customer details for dine-in
#     'dine-in',
#     '2024-04-03 12:05:00',
#     6.93,
#     1.40,
#     1,
#     NULL, NULL, NULL, NULL, NULL, -- No delivery address
#     4,                            -- Table number for dine-in
#     NULL,                         -- Not a pickup
#     'Small', 'Original',
#     6.93, 1.40,
#     'Regular Cheese,Chicken,Banana Peppers',
#     NULL, NULL                          -- No discount
# );

CALL AddSingleOrderWithMultiplePizzas(
    'Andrew',
    'Wilkes-Krier',
    '8642545861',
    'pickup',
    '2024-03-03 21:30:00',
    89.28, -- Total price for 6 pizzas
    19.80, -- Total cost for 6 pizzas
    1,
    NULL, NULL, NULL, NULL, NULL, -- No delivery address
    NULL,                         -- No table number
    1,                            -- Picked up
    'Large,Large,Large,Large,Large,Large,', 'Original',
    '14.88', '3.30',
    'Regular Cheese,Pepperoni',
    NULL, NULL                          -- No discount
);

CALL AddSingleOrderWithMultiplePizzas(
    'Andrew',
    'Wilkes-Krier',
    '8642545861',
    'delivery',
    '2024-04-20 19:11:00',
    68.95,
    23.62,
    1,
    115, 'Party Blvd', 'Anderson', 'SC', 29621, -- Delivery address
    NULL,                     -- No table number
    NULL,                     -- Not a pickup
    'XLarge,XLarge,XLarge,', 'Original,Original,Original',
    '27.94,31.50,26.75', '9.19,6.25,8.28,8.18',
    'Pepperoni,Sausage;Ham,Pineapple;Chicken,Bacon',
    'NULL,Specialty Pizza,NULL', 'Gameday Special'          -- Discount applied
);

# CALL AddSingleOrderWithMultiplePizzas(
#     'Andrew',
#     'Wilkes-Krier',
#     '8642545861',
#     'delivery',
#     '2024-04-20 19:11:00',
#     31.50,
#     6.25,
#     1,
#     115, 'Party Blvd', 'Anderson', 'SC', 29621, -- Delivery address
#     NULL,                     -- No table number
#     NULL,                     -- Not a pickup
#     'XLarge,XLarge', 'Original,Original',
#     '31.50,26.75', '6.25,8.18',
#     'Ham,Pineapple;Chicken,Bacon',
#     'Specialty Pizza,NULL', 'Gameday Special,Gameday Special'        -- Discount applied
# );

# CALL AddSingleOrderWithMultiplePizzas(
#     'Andrew',
#     'Wilkes-Krier',
#     '8642545861',
#     'delivery',
#     '2024-04-20 19:11:00',
#     26.75,
#     8.18,
#     1,
#     115, 'Party Blvd', 'Anderson', 'SC', 29621, -- Delivery address
#     NULL,                     -- No table number
#     NULL,                     -- Not a pickup
#     'XLarge', 'Original',
#     26.75, 8.18,
#     'Chicken,Bacon',
#     NULL, 'Gameday Special'                      -- No discount
# );

-- Order 5: March 2nd - Pickup by Matt Engers
CALL AddSingleOrderWithMultiplePizzas(
    'Matt',
    'Engers',
    '8644749953',
    'pickup',
    '2024-03-02 17:30:00',
    27.45,
    7.88,
    1,
    NULL, NULL, NULL, NULL, NULL, -- No delivery address
    NULL,                         -- No table number
    1,                            -- Picked up
    'XLarge,', 'Gluten-Free',
    '27.45', '7.88',
    'Green Pepper,Onion,Roma Tomatoes,Mushrooms,Black Olives,Goat Cheese',
    'Specialty Pizza', NULL             -- Discount applied
);

-- Order 6: March 2nd - Delivery by Frank Turner
CALL AddSingleOrderWithMultiplePizzas(
    'Frank',
    'Turner',
    '8642328944',
    'delivery',
    '2024-03-02 18:17:00',
    25.81,
    4.24,
    1,
    6745, 'Wessex St', 'Anderson', 'SC', 29621, -- Delivery address
    NULL,                     -- No table number
    NULL,                     -- Not a pickup
    'Large,', 'Thin',
    25.81, 4.24,
    'Chicken,Green Pepper,Onion,Mushrooms,Four Cheese Blend',
    NULL, NULL                      -- No discount
);

-- Order 7: April 13th - Delivery by Milo Auckerman
CALL AddSingleOrderWithMultiplePizzas(
    'Milo',
    'Auckerman',
    '8648785679',
    'delivery',
    '2024-04-13 20:32:00',
    31.66,
    6,
    1,
    8879, 'Suburban', 'Anderson', 'SC', 29621, -- Delivery address
    NULL,                     -- No table number
    NULL,                     -- Not a pickup
    'Large,Large,', 'Thin,Thin',
    '18.00,19.25', '2.75,3.25',
    'Four Cheese Blend;Regular Cheese,Pepperoni',
    'NULL,NULL', 'Employee'                -- Discount applied
);

# CALL AddSingleOrderWithMultiplePizzas(
#     'Milo',
#     'Auckerman',
#     '8648785679',
#     'delivery',
#     '2024-04-13 20:32:00',
#     19.25,
#     3.25,
#     1,
#     8879, 'Suburban', 'Anderson', 'SC', 29621, -- Delivery address
#     NULL,                     -- No table number
#     NULL,                     -- Not a pickup
#     'Large', 'Thin',
#     19.25, 3.25,
#     'Regular Cheese,Pepperoni',
#     NULL, 'Employee'                -- Discount applied
# );