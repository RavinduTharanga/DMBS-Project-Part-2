USE PizzaDB;

DELIMITER //

-- Stored Procedure 1: Calculate and update pizza price and cost
CREATE PROCEDURE CalculatePizzaPriceAndCost(
    IN p_pizza_id INT,
    OUT p_total_price DECIMAL(6,2),
    OUT p_total_cost DECIMAL(6,2)
)
BEGIN
    DECLARE base_price DECIMAL(6,2);
    DECLARE base_cost DECIMAL(6,2);
    DECLARE topping_price DECIMAL(6,2) DEFAULT 0;
    DECLARE topping_cost DECIMAL(6,2) DEFAULT 0;
    DECLARE discount_amount DECIMAL(6,2) DEFAULT 0;
    
    -- Get base price and cost
    SELECT bp.BasePrice, bp.BaseCost 
    INTO base_price, base_cost
    FROM Pizza p
    JOIN BasePizza bp ON p.BasePizzaID = bp.BasePizzaID
    WHERE p.PizzaID = p_pizza_id;
    
    -- Calculate toppings price and cost
    SELECT 
        SUM(CASE WHEN pt.ExtraTopping = 1 THEN t.PricePerUnit * 2 ELSE t.PricePerUnit END),
        SUM(CASE WHEN pt.ExtraTopping = 1 THEN t.CostPerUnit * 2 ELSE t.CostPerUnit END)
    INTO topping_price, topping_cost
    FROM PizzaTopping pt
    JOIN Topping t ON pt.ToppingID = t.ToppingID
    WHERE pt.PizzaID = p_pizza_id;
    
    -- Calculate discounts
    SELECT COALESCE(SUM(
        CASE 
            WHEN d.PercentOff IS NOT NULL THEN (base_price + COALESCE(topping_price, 0)) * (d.PercentOff/100)
            ELSE d.DollarOff
        END
    ), 0)
    INTO discount_amount
    FROM PizzaDiscount pd
    JOIN Discount d ON pd.DiscountID = d.DiscountID
    WHERE pd.PizzaID = p_pizza_id;
    
    -- Set final price and cost
    SET p_total_price = base_price + COALESCE(topping_price, 0) - discount_amount;
    SET p_total_cost = base_cost + COALESCE(topping_cost, 0);
    
    -- Update the pizza
    UPDATE Pizza 
    SET PizzaPrice = p_total_price, PizzaCost = p_total_cost
    WHERE PizzaID = p_pizza_id;
END //

-- Stored Procedure 2: Calculate and update order total
CREATE PROCEDURE CalculateOrderTotal(
    IN p_order_id INT
)
BEGIN
    DECLARE order_price DECIMAL(6,2);
    DECLARE order_cost DECIMAL(6,2);
    DECLARE order_discount DECIMAL(6,2) DEFAULT 0;
    
    -- Sum all pizza prices and costs
    SELECT SUM(PizzaPrice), SUM(PizzaCost)
    INTO order_price, order_cost
    FROM Pizza
    WHERE OrderID = p_order_id;
    
    -- Calculate order level discounts
    SELECT COALESCE(SUM(
        CASE 
            WHEN d.PercentOff IS NOT NULL THEN order_price * (d.PercentOff/100)
            ELSE d.DollarOff
        END
    ), 0)
    INTO order_discount
    FROM OrderDiscount od
    JOIN Discount d ON od.DiscountID = d.DiscountID
    WHERE od.OrderID = p_order_id;
    
    -- Update the order
    UPDATE Orders 
    SET OrderPrice = order_price - order_discount,
        OrderCost = order_cost
    WHERE OrderID = p_order_id;
END //

-- Function 1: Calculate Pizza Base Price
CREATE FUNCTION CalculateBasePrice(
    p_size VARCHAR(10),
    p_crust_type VARCHAR(20)
) RETURNS DECIMAL(6,2)
DETERMINISTIC
BEGIN
    DECLARE base_price DECIMAL(6,2);
    
    SELECT BasePrice INTO base_price
    FROM BasePizza
    WHERE Size = p_size AND CrustType = p_crust_type;
    
    RETURN COALESCE(base_price, 0);
END //

-- Function 2: Check if topping inventory is sufficient
CREATE FUNCTION IsInventorySufficient(
    p_topping_id INT,
    p_pizza_size VARCHAR(10),
    p_is_extra BOOLEAN
) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE required_units DECIMAL(6,2);
    DECLARE current_inventory INT;
    
    SELECT 
        CASE p_pizza_size
            WHEN 'Small' THEN SmallUnits
            WHEN 'Medium' THEN MediumUnits
            WHEN 'Large' THEN LargeUnits
            WHEN 'XLarge' THEN XLargeUnits
        END * IF(p_is_extra, 2, 1),
        CurrentInventory
    INTO required_units, current_inventory
    FROM Topping
    WHERE ToppingID = p_topping_id;
    
    RETURN current_inventory >= required_units;
END //

-- Trigger 1: Before Insert on PizzaTopping
CREATE TRIGGER before_pizzatopping_insert
BEFORE INSERT ON PizzaTopping
FOR EACH ROW
BEGIN
    DECLARE pizza_size VARCHAR(10);
    
    -- Get pizza size
    SELECT bp.Size INTO pizza_size
    FROM Pizza p
    JOIN BasePizza bp ON p.BasePizzaID = bp.BasePizzaID
    WHERE p.PizzaID = NEW.PizzaID;
    
    -- Check inventory
    IF NOT IsInventorySufficient(NEW.ToppingID, pizza_size, NEW.ExtraTopping) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient topping inventory';
    END IF;
    
    -- Update inventory
    UPDATE Topping
    SET CurrentInventory = CurrentInventory - (
        CASE pizza_size
            WHEN 'Small' THEN SmallUnits
            WHEN 'Medium' THEN MediumUnits
            WHEN 'Large' THEN LargeUnits
            WHEN 'XLarge' THEN XLargeUnits
        END * IF(NEW.ExtraTopping, 2, 1)
    )
    WHERE ToppingID = NEW.ToppingID;
END //

-- Trigger 2: After Insert on Pizza
CREATE TRIGGER after_pizza_insert
AFTER INSERT ON Pizza
FOR EACH ROW
BEGIN
    -- Recalculate order totals when a new pizza is added
    CALL CalculateOrderTotal(NEW.OrderID);
END //

-- Trigger 3: Before Update on Topping
CREATE TRIGGER before_topping_update
BEFORE UPDATE ON Topping
FOR EACH ROW
BEGIN
    -- Check if inventory falls below minimum
    IF NEW.CurrentInventory < NEW.MinimumInventory THEN
        SET NEW.CurrentInventory = OLD.CurrentInventory;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Warning: Topping inventory below minimum level';
    END IF;
END //

-- Trigger 4: After Update on Pizza
CREATE TRIGGER after_pizza_update
AFTER UPDATE ON Pizza
FOR EACH ROW
BEGIN
    -- If price or cost changes, recalculate order totals
    IF NEW.PizzaPrice != OLD.PizzaPrice OR NEW.PizzaCost != OLD.PizzaCost THEN
        CALL CalculateOrderTotal(NEW.OrderID);
    END IF;
END //

DELIMITER ;
