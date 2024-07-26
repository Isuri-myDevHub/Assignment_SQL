DELIMITER //

CREATE PROCEDURE InsertProducts(IN product_json JSON)
BEGIN
    -- Insert Products
    INSERT INTO Products (name, description, category, image, status)
    SELECT name, description, category, image, status 
    FROM JSON_TABLE(product_json, '$.products[*]'
        COLUMNS (
            name VARCHAR(255) PATH '$.name',
            description TEXT PATH '$.description',
            category VARCHAR(255) PATH '$.category',
            image VARCHAR(255) PATH '$.image',
            status VARCHAR(50) PATH '$.status'
        )
    );

    -- Get Product IDs
    CREATE TEMPORARY TABLE TempProductIDs AS
    SELECT id FROM Products ORDER BY id DESC LIMIT JSON_LENGTH(product_json, '$.products');

    -- Insert Tags
    INSERT IGNORE INTO Tags (tag)
    SELECT DISTINCT tag
    FROM JSON_TABLE(product_json, '$.products[*].tags[*]'
        COLUMNS (
            tag VARCHAR(50) PATH '$'
        )
    );

    -- Insert ProductTags
    INSERT INTO ProductTags (product_id, tag_id)
    SELECT p.id, t.id
    FROM TempProductIDs p
    JOIN JSON_TABLE(product_json, '$.products[*].tags[*]'
        COLUMNS (
            tag VARCHAR(50) PATH '$'
        )
    ) jt
    JOIN Tags t ON jt.tag = t.tag;

    -- Insert Restrictions
    INSERT INTO Restrictions (product_id, type, subtype, value)
    SELECT p.id, jt.type, jt.subType, jt.value
    FROM TempProductIDs p
    JOIN JSON_TABLE(product_json, '$.products[*].restrictions[*]'
        COLUMNS (
            type VARCHAR(50) PATH '$.type',
            subType VARCHAR(50) PATH '$.subType',
            value INT PATH '$.value'
        )
    ) jt;

    -- Insert Types
    INSERT INTO Types (product_id, name, price, status, currency)
    SELECT p.id, jt.name, jt.price, jt.status, jt.currency
    FROM TempProductIDs p
    JOIN JSON_TABLE(product_json, '$.products[*].types[*]'
        COLUMNS (
            name VARCHAR(255) PATH '$.name',
            price DECIMAL(10, 2) PATH '$.price',
            status VARCHAR(50) PATH '$.status',
            currency VARCHAR(10) PATH '$.currency'
        )
    ) jt;

    -- Get Type IDs
    CREATE TEMPORARY TABLE TempTypeIDs AS
    SELECT id FROM Types ORDER BY id DESC LIMIT JSON_LENGTH(product_json, '$.products[*].types');

    -- Insert Distributions
    INSERT INTO Distributions (type_id, name, amount)
    SELECT t.id, jt.name, jt.amount
    FROM TempTypeIDs t
    JOIN JSON_TABLE(product_json, '$.products[*].types[*].distributions[*]'
        COLUMNS (
            name VARCHAR(255) PATH '$.name',
            amount DECIMAL(10, 2) PATH '$.amount'
        )
    ) jt;

    -- Clean up temporary tables
    DROP TEMPORARY TABLE IF EXISTS TempProductIDs;
    DROP TEMPORARY TABLE IF EXISTS TempTypeIDs;
END //

DELIMITER ;
