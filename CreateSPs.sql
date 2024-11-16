DELIMITER //

CREATE PROCEDURE AddSingleOrder (
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
    IN p_Size VARCHAR(30),             -- Pizza size
    IN p_Crust VARCHAR(30),            -- Pizza crust type
    IN p_PizzaPrice DECIMAL(5,2),      -- Pizza price
    IN p_PizzaCost DECIMAL(5,2),       -- Pizza cost
    IN p_Toppings TEXT,                -- Comma-separated list of toppings
    IN p_PizzaDiscounts TEXT,          -- Comma-separated list of pizza discounts
    IN p_OrderDiscounts TEXT           -- Comma-separated list of order discounts
)
BEGIN
    -- Declare variables at the start
    DECLARE customer_id INT;
    DECLARE pizza_discount_name VARCHAR(30);
    DECLARE order_discount_name VARCHAR(30);
    DECLARE current_discount VARCHAR(30);

    -- Step 1: Insert Customer (if provided)
    IF p_FName IS NOT NULL AND p_LName IS NOT NULL THEN
        SET customer_id = (SELECT customer_CustID FROM customer WHERE customer_FName = p_FName AND customer_LName = p_LName AND customer_PhoneNum = p_PhoneNum);
        IF customer_id IS NULL THEN
            INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum)
            VALUES (p_FName, p_LName, p_PhoneNum);
            SET customer_id = LAST_INSERT_ID();
        END IF;
    ELSE
        SET customer_id = NULL;  -- For dine-in orders without customer details
    END IF;

    -- Step 2: Insert Order
    INSERT INTO ordertable (customer_CustID, ordertable_OrderType, ordertable_OrderDateTime, ordertable_CustPrice, ordertable_BusPrice, ordertable_isComplete)
    VALUES (customer_id, p_OrderType, p_OrderDateTime, p_CustPrice, p_BusPrice, p_isComplete);
    SET @OrderID = LAST_INSERT_ID();

    -- Step 3: Handle Delivery, Dine-in, or Pickup
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

    -- Step 4: Insert Pizza
    INSERT INTO pizza (pizza_Size, pizza_CrustType, pizza_OrderID, pizza_PizzaState, pizza_PizzaDate, pizza_CustPrice, pizza_BusPrice)
    VALUES (p_Size, p_Crust, @OrderID, 'Completed', p_OrderDateTime, p_PizzaPrice, p_PizzaCost);
    SET @PizzaID = LAST_INSERT_ID();

    -- Step 5: Add Toppings
    INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
    SELECT @PizzaID, topping_TopID, 0  -- Assume single topping by default
    FROM topping
    WHERE FIND_IN_SET(topping_TopName, p_Toppings);

    -- Step 6: Apply Pizza Discounts
    WHILE LOCATE(',', p_PizzaDiscounts) > 0 DO
        SET pizza_discount_name = SUBSTRING_INDEX(p_PizzaDiscounts, ',', 1);
        SET p_PizzaDiscounts = SUBSTRING(p_PizzaDiscounts FROM LOCATE(',', p_PizzaDiscounts) + 1);

        INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
        SELECT @PizzaID, discount_DiscountID
        FROM discount
        WHERE discount_DiscountName = pizza_discount_name;
    END WHILE;

    -- Handle the last or only pizza discount
    IF p_PizzaDiscounts IS NOT NULL AND p_PizzaDiscounts != '' THEN
        INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
        SELECT @PizzaID, discount_DiscountID
        FROM discount
        WHERE discount_DiscountName = p_PizzaDiscounts;
    END IF;

    -- Step 7: Apply Order Discounts
    WHILE LOCATE(',', p_OrderDiscounts) > 0 DO
        SET order_discount_name = SUBSTRING_INDEX(p_OrderDiscounts, ',', 1);
        SET p_OrderDiscounts = SUBSTRING(p_OrderDiscounts FROM LOCATE(',', p_OrderDiscounts) + 1);

        INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID)
        SELECT @OrderID, discount_DiscountID
        FROM discount
        WHERE discount_DiscountName = order_discount_name;
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
    SELECT topping_CurINV, topping_MinINV
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

-- Update trigger

DELIMITER //

CREATE TRIGGER UpdateInventoryAfterOrder
AFTER UPDATE ON pizza_topping
FOR EACH ROW
BEGIN
    IF NEW.pizza_topping_IsDouble = 1 THEN
        UPDATE topping
        SET topping_CurINVT = topping_CurINVT - 2
        WHERE topping_TopID = NEW.topping_TopID;
    ELSE
        UPDATE topping
        SET topping_CurINVT = topping_CurINVT - 1
        WHERE topping_TopID = NEW.topping_TopID;
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER AutoMarkOrderComplete
AFTER UPDATE ON pizza
FOR EACH ROW
BEGIN
    DECLARE total_pizzas INT;
    DECLARE completed_pizzas INT;

    -- Count total and completed pizzas for the order
    SELECT COUNT(*), SUM(pizza_PizzaState = 'Completed')
    INTO total_pizzas, completed_pizzas
    FROM pizza
    WHERE pizza_OrderID = NEW.pizza_OrderID;

    -- Mark the order as complete if all pizzas are completed
    IF total_pizzas = completed_pizzas THEN
        UPDATE ordertable
        SET ordertable_isComplete = 1
        WHERE ordertable_OrderID = NEW.pizza_OrderID;
    END IF;
END //

DELIMITER ;

-- insert Trigger

DELIMITER //

CREATE TRIGGER UpdateToppingInventory
AFTER INSERT ON pizza_topping
FOR EACH ROW
BEGIN
    IF NEW.pizza_topping_IsDouble = 1 THEN
        -- Reduce inventory by 2 for double toppings
        UPDATE topping
        SET topping_CurINV = topping_CurINV - 2
        WHERE topping_TopID = NEW.topping_TopID;
    ELSE
        -- Reduce inventory by 1 for single topping
        UPDATE topping
        SET topping_CurINV = topping_CurINV - 1
        WHERE topping_TopID = NEW.topping_TopID;
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER SetOrderIncomplete
BEFORE INSERT ON ordertable
FOR EACH ROW
BEGIN
    SET NEW.ordertable_isComplete = 0;
END //

DELIMITER ;

