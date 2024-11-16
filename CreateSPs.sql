DELIMITER //

CREATE PROCEDURE AddSingleOrderWithMultiplePizzas (
    IN p_FName VARCHAR(30),            -- Customer first name (optional for dine-in)
    IN p_LName VARCHAR(30),            -- Customer last name (optional for dine-in)
    IN p_PhoneNum VARCHAR(30),         -- Customer phone number (optional for dine-in)
    IN p_OrderType VARCHAR(30),        -- Order type: delivery, dine-in, or pickup
    IN p_OrderDateTime DATETIME,       -- Date and time of the order
    IN p_CustPrice DECIMAL(5,2),       -- Total price charged to the customer
    IN p_BusPrice DECIMAL(5,2),        -- Total business cost for the order
    IN p_isComplete TINYINT,           -- 1 for complete, 0 for incomplete
    IN p_HouseNum INT,                 -- Delivery address house number (delivery only)
    IN p_Street VARCHAR(30),           -- Delivery address street (delivery only)
    IN p_City VARCHAR(30),             -- Delivery address city (delivery only)
    IN p_State VARCHAR(2),             -- Delivery address state (delivery only)
    IN p_Zip INT,                      -- Delivery address zip code (delivery only)
    IN p_TableNum INT,                 -- Table number (dine-in only)
    IN p_IsPickedUp TINYINT,           -- 1 if the pickup order is picked up, 0 otherwise
    IN p_PizzaSizes TEXT,              -- Comma-separated list of pizza sizes
    IN p_PizzaCrusts TEXT,             -- Comma-separated list of pizza crust types
    IN p_PizzaPrices TEXT,             -- Comma-separated list of pizza prices
    IN p_PizzaCosts TEXT,              -- Comma-separated list of pizza costs
    IN p_ToppingsList TEXT,            -- Comma-separated list of toppings for each pizza
    IN p_PizzaDiscountsList TEXT,      -- Comma-separated list of discounts for each pizza
    IN p_OrderDiscounts TEXT           -- Comma-separated list of order discounts
)
BEGIN
    -- Declare variables
    DECLARE customer_id INT;
    DECLARE pizza_size VARCHAR(30);
    DECLARE pizza_crust VARCHAR(30);
    DECLARE pizza_price DECIMAL(5,2);
    DECLARE pizza_cost DECIMAL(5,2);
    DECLARE toppings TEXT;
    DECLARE pizza_discounts TEXT;
    DECLARE discount_name VARCHAR(30);
    DECLARE topping_name VARCHAR(30);
    DECLARE pizza_id INT;

    -- Insert Customer
    IF p_FName IS NOT NULL AND p_LName IS NOT NULL THEN
        SELECT customer_CustID
        INTO customer_id
        FROM customer
        WHERE LOWER(customer_FName) = LOWER(p_FName)
          AND LOWER(customer_LName) = LOWER(p_LName)
          AND customer_PhoneNum = p_PhoneNum
        LIMIT 1;

        IF customer_id IS NULL THEN
            INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum)
            VALUES (p_FName, p_LName, p_PhoneNum);
            SET customer_id = LAST_INSERT_ID();
        END IF;
    ELSE
        SET customer_id = NULL;
    END IF;

    -- Insert Order
    INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime, ordertable_CustPrice, ordertable_BusPrice, ordertable_isComplete)
    VALUES (customer_id, p_OrderType, p_OrderDateTime, p_CustPrice, p_BusPrice, p_isComplete);
    SET @OrderID = LAST_INSERT_ID();

    -- Handle Delivery, Dine-in, or Pickup
    IF p_OrderType = 'delivery' THEN
        INSERT INTO delivery (ordertable_OrderID, delivery_HouseNum, delivery_Street, delivery_City, delivery_State, delivery_Zip, delivery_IsDelivered)
        VALUES (@OrderID, p_HouseNum, p_Street, p_City, p_State, p_Zip, 0);
    ELSEIF p_OrderType = 'dine-in' THEN
        INSERT INTO dinein (ordertable_OrderID, dinein_TableNum)
        VALUES (@OrderID, p_TableNum);
    ELSEIF p_OrderType = 'pickup' THEN
        INSERT INTO pickup (ordertable_OrderID, pickup_IsPickedUp)
        VALUES (@OrderID, p_IsPickedUp);
    END IF;

    -- Handle Pizzas
    WHILE LOCATE(',', p_PizzaSizes) > 0 DO
        -- Extract pizza details
        SET pizza_size = TRIM(SUBSTRING_INDEX(p_PizzaSizes, ',', 1));
        SET pizza_crust = TRIM(SUBSTRING_INDEX(p_PizzaCrusts, ',', 1));
        SET pizza_price = TRIM(SUBSTRING_INDEX(p_PizzaPrices, ',', 1));
        SET pizza_cost = TRIM(SUBSTRING_INDEX(p_PizzaCosts, ',', 1));
        SET toppings = TRIM(SUBSTRING_INDEX(p_ToppingsList, ',', 1));
        SET pizza_discounts = TRIM(SUBSTRING_INDEX(p_PizzaDiscountsList, ',', 1));

        -- Remove the processed details from the lists
        SET p_PizzaSizes = SUBSTRING(p_PizzaSizes FROM LOCATE(',', p_PizzaSizes) + 1);
        SET p_PizzaCrusts = SUBSTRING(p_PizzaCrusts FROM LOCATE(',', p_PizzaCrusts) + 1);
        SET p_PizzaPrices = SUBSTRING(p_PizzaPrices FROM LOCATE(',', p_PizzaPrices) + 1);
        SET p_PizzaCosts = SUBSTRING(p_PizzaCosts FROM LOCATE(',', p_PizzaCosts) + 1);
        SET p_ToppingsList = SUBSTRING(p_ToppingsList FROM LOCATE(',', p_ToppingsList) + 1);
        SET p_PizzaDiscountsList = SUBSTRING(p_PizzaDiscountsList FROM LOCATE(',', p_PizzaDiscountsList) + 1);

        -- Insert Pizza
        INSERT INTO pizza (pizza_Size, pizza_CrustType, pizza_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
        VALUES (pizza_size, pizza_crust, @OrderID, 'Completed', p_OrderDateTime, pizza_price, pizza_cost);
        SET pizza_id = LAST_INSERT_ID();

        -- Add Toppings
        INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
        SELECT pizza_id, topping_TopID, 0
        FROM topping
        WHERE FIND_IN_SET(topping_TopName, toppings);

        -- Add Discounts for Pizza
        WHILE LOCATE(',', pizza_discounts) > 0 DO
            SET discount_name = TRIM(SUBSTRING_INDEX(pizza_discounts, ',', 1));
            INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
            SELECT pizza_id, discount_DiscountID
            FROM discount
            WHERE discount_DiscountName = discount_name;
            SET pizza_discounts = SUBSTRING(pizza_discounts FROM LOCATE(',', pizza_discounts) + 1);
        END WHILE;

        -- Handle the last or only pizza discount
        IF pizza_discounts IS NOT NULL AND pizza_discounts != '' THEN
            INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
            SELECT pizza_id, discount_DiscountID
            FROM discount
            WHERE discount_DiscountName = pizza_discounts;
        END IF;

    -- Check if we have more pizza sizes to process, exit condition
    END WHILE;

    -- Apply Order Discounts
    WHILE LOCATE(',', p_OrderDiscounts) > 0 DO
        SET discount_name = TRIM(SUBSTRING_INDEX(p_OrderDiscounts, ',', 1));
        INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID)
        SELECT @OrderID, discount_DiscountID
        FROM discount
        WHERE discount_DiscountName = discount_name;
        SET p_OrderDiscounts = SUBSTRING(p_OrderDiscounts FROM LOCATE(',', p_OrderDiscounts) + 1);
    END WHILE;

    -- Handle the last or only order discount
    IF p_OrderDiscounts IS NOT NULL AND p_OrderDiscounts != '' THEN
        INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID)
        SELECT @OrderID, discount_DiscountID
        FROM discount
        WHERE discount_DiscountName = p_OrderDiscounts;
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE CalculateInventoryStatus(
    IN p_ToppingName VARCHAR(30),
    OUT p_Status VARCHAR(50)
)
BEGIN
    DECLARE cur_inventory INT;
    DECLARE min_inventory INT;

    -- Get the current and minimum inventory levels
    SELECT topping_CurINVT, topping_MinINVT
    INTO cur_inventory, min_inventory
    FROM topping
    WHERE topping_TopName = p_ToppingName;

    -- Determine inventory status
    IF cur_inventory < min_inventory THEN
        SET p_Status = CONCAT(p_ToppingName, ' is below the required inventory level!');
    ELSE
        SET p_Status = CONCAT(p_ToppingName, ' has sufficient inventory.');
    END IF;
END //

DELIMITER ;


-- Stored Functions
DELIMITER //

CREATE FUNCTION CalculateOrderCost (
    p_OrderID INT
) RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE totalCost DECIMAL(10,2);
    SET totalCost = (
        SELECT SUM(pizza_CustPrice)
        FROM pizza
        WHERE pizza_OrderID = p_OrderID
    );
    RETURN totalCost;
END //

DELIMITER ;

DELIMITER //

CREATE FUNCTION GetCustomerOrderCount(customer_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE order_count INT;
    SELECT COUNT(*)
    INTO order_count
    FROM ordertable
    WHERE customer_CustID = customer_id;
    RETURN order_count;
END //

DELIMITER ;

# -- Update trigger
#
# DELIMITER //
#
# CREATE TRIGGER UpdateInventoryAfterOrder
# AFTER UPDATE ON pizza_topping
# FOR EACH ROW
# BEGIN
#     IF NEW.pizza_topping_IsDouble = 1 THEN
#         UPDATE topping
#         SET topping_CurINVT = topping_CurINVT - 2
#         WHERE topping_TopID = NEW.topping_TopID;
#     ELSE
#         UPDATE topping
#         SET topping_CurINVT = topping_CurINVT - 1
#         WHERE topping_TopID = NEW.topping_TopID;
#     END IF;
# END //
#
# DELIMITER ;
#
# DELIMITER //
#
# CREATE TRIGGER AutoMarkOrderComplete
# AFTER UPDATE ON pizza
# FOR EACH ROW
# BEGIN
#     DECLARE total_pizzas INT;
#     DECLARE completed_pizzas INT;
#
#     -- Count total and completed pizzas for the order
#     SELECT COUNT(*), SUM(pizza_PizzaState = 'Completed')
#     INTO total_pizzas, completed_pizzas
#     FROM pizza
#     WHERE pizza_OrderID = NEW.pizza_OrderID;
#
#     -- Mark the order as complete if all pizzas are completed
#     IF total_pizzas = completed_pizzas THEN
#         UPDATE ordertable
#         SET ordertable_isComplete = 1
#         WHERE ordertable_OrderID = NEW.pizza_OrderID;
#     END IF;
# END //
#
# DELIMITER ;
#
# -- insert Trigger
#
# DELIMITER //
#
# CREATE TRIGGER DefOrderType
# BEFORE INSERT ON ordertable
# FOR EACH ROW
#     BEGIN
#         IF NEW.ordertable_OrderType IS NULL THEN
#             SET NEW.ordertable_OrderType = 'dinein';
#         end if;
#     end //
#
# DELIMITER ;
#
# DELIMITER //
#
# CREATE TRIGGER SetOrderIncomplete
# BEFORE INSERT ON ordertable
# FOR EACH ROW
# BEGIN
#     SET NEW.ordertable_isComplete = ;
# END //
#
# DELIMITER ;

