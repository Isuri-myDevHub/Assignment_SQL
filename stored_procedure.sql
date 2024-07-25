DELIMITER //

CREATE PROCEDURE InsertProducts(IN product_json JSON)
BEGIN
    DECLARE prod_id INT;
    DECLARE product_name VARCHAR(255);
    DECLARE product_description TEXT;
    DECLARE product_category VARCHAR(255);
    DECLARE product_image VARCHAR(255);
    DECLARE product_status VARCHAR(50);

    DECLARE done INT DEFAULT FALSE;

    DECLARE cur CURSOR FOR
        SELECT name, description, category, image, status FROM JSON_TABLE(product_json, '$.products[*]'
                                                                          COLUMNS (
                                                                              name VARCHAR(255) PATH '$.name',
                                                                              description TEXT PATH '$.description',
                                                                              category VARCHAR(255) PATH '$.category',
                                                                              image VARCHAR(255) PATH '$.image',
                                                                              status VARCHAR(50) PATH '$.status'
                                                                              )
            );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO product_name, product_description, product_category, product_image, product_status;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insert Product
        INSERT INTO Products (name, description, category, image, status)
        VALUES (product_name, product_description, product_category, product_image, product_status);
        SET prod_id = LAST_INSERT_ID();

        -- Insert Tags
        CALL InsertTags(product_json, prod_id);

        -- Insert Restrictions
        CALL InsertRestrictions(product_json, prod_id);

        -- Insert Types
        CALL InsertTypes(product_json, prod_id);
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;


CREATE PROCEDURE InsertTags(IN product_json JSON, IN prod_id INT)
BEGIN
    DECLARE tag VARCHAR(50);
    DECLARE done INT DEFAULT FALSE;
    DECLARE tag_id INT;


    DECLARE tag_cursor CURSOR FOR
        SELECT tag FROM JSON_TABLE(product_json, '$.products[*].tags[*]'
                                   COLUMNS (
                                       tag VARCHAR(50) PATH '$'
                                       )
            );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN tag_cursor;
    tag_loop: LOOP
        FETCH tag_cursor INTO tag;

        IF done THEN
            LEAVE tag_loop;
        END IF;

        INSERT IGNORE INTO Tags (tag) VALUES (tag);
        SELECT id INTO tag_id FROM Tags WHERE tag = tag;
        INSERT INTO ProductTags (product_id, tag_id) VALUES (prod_id, tag_id);
    END LOOP;

    CLOSE tag_cursor;
END;


CREATE PROCEDURE InsertRestrictions(IN product_json JSON, IN prod_id INT)
BEGIN
    DECLARE res_type VARCHAR(50);
    DECLARE res_subtype VARCHAR(50);
    DECLARE res_value INT;
    DECLARE done INT DEFAULT FALSE;

    DECLARE restriction_cursor CURSOR FOR
        SELECT type, subtype, value FROM JSON_TABLE(product_json, '$.products[*].restrictions[*]'
                                                    COLUMNS (
                                                        type VARCHAR(50) PATH '$.type',
                                                        subtype VARCHAR(50) PATH '$.subType',
                                                        value INT PATH '$.value'
                                                        )
            );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN restriction_cursor;
    restriction_loop: LOOP
        FETCH restriction_cursor INTO res_type, res_subtype, res_value;

        IF done THEN
            LEAVE restriction_loop;
        END IF;

        INSERT INTO Restrictions (product_id, type, subtype, value)
        VALUES (prod_id, res_type, res_subtype, res_value);
    END LOOP;

    CLOSE restriction_cursor;
END;

CREATE PROCEDURE InsertTypes(IN product_json JSON, IN prod_id INT)
BEGIN
    DECLARE type_name VARCHAR(255);
    DECLARE type_price DECIMAL(10, 2);
    DECLARE type_status VARCHAR(50);
    DECLARE type_currency VARCHAR(10);
    DECLARE done INT DEFAULT FALSE;

    DECLARE type_cursor CURSOR FOR
        SELECT name, price, status, currency FROM JSON_TABLE(product_json, '$.products[*].types[*]'
                                                             COLUMNS (
                                                                 name VARCHAR(255) PATH '$.name',
                                                                 price DECIMAL(10, 2) PATH '$.price',
                                                                 status VARCHAR(50) PATH '$.status',
                                                                 currency VARCHAR(10) PATH '$.currency'
                                                                 )
            );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    DECLARE type_id INT;


    OPEN type_cursor;
    type_loop: LOOP
        FETCH type_cursor INTO type_name, type_price, type_status, type_currency;

        IF done THEN
            LEAVE type_loop;
        END IF;

        INSERT INTO Types (product_id, name, price, status, currency)
        VALUES (prod_id, type_name, type_price, type_status, type_currency);
        SET type_id = LAST_INSERT_ID();

        -- Insert Distributions
        CALL InsertDistributions(product_json, type_id);
    END LOOP;

    CLOSE type_cursor;
END;

CREATE PROCEDURE InsertDistributions(IN product_json JSON, IN type_id INT)
BEGIN
    DECLARE dist_name VARCHAR(255);
    DECLARE dist_amount DECIMAL(10, 2);
    DECLARE done INT DEFAULT FALSE;

    DECLARE distribution_cursor CURSOR FOR
        SELECT name, amount FROM JSON_TABLE(product_json, '$.products[*].types[*].distributions[*]'
                                            COLUMNS (
                                                name VARCHAR(255) PATH '$.name',
                                                amount DECIMAL(10, 2) PATH '$.amount'
                                                )
            );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN distribution_cursor;
    distribution_loop: LOOP
        FETCH distribution_cursor INTO dist_name, dist_amount;

        IF done THEN
            LEAVE distribution_loop;
        END IF;

        INSERT INTO Distributions (type_id, name, amount)
        VALUES (type_id, dist_name, dist_amount);
    END LOOP;

    CLOSE distribution_cursor;
END;
