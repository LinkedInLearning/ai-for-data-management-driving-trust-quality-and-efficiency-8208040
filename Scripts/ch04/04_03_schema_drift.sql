-- =============================================================================
-- Course: AI for Data Management
-- Asset:  Schema drift demo — Ch4 video 04_03
-- Simulates a breaking schema change on the products table:
--   unit_price (DECIMAL) renamed to sale_price
-- This is the root cause of the RUN0014 failure in 04_02.
-- Feed both DDL blocks to AI and ask it to classify the change,
-- map downstream impact, and suggest remediation steps.
-- =============================================================================


-- BEFORE: original products table
-- =============================================================================
CREATE TABLE products (
    product_id   VARCHAR(10)    NOT NULL PRIMARY KEY,
    product_name VARCHAR(100)   NOT NULL,
    category     VARCHAR(50)    NOT NULL,
    unit_price   DECIMAL(10,2)  NOT NULL,   -- <-- original column name
    supplier_id  VARCHAR(10)    NOT NULL
        REFERENCES suppliers(supplier_id)
);


-- AFTER: column renamed by upstream team without notice
-- =============================================================================
CREATE TABLE products (
    product_id   VARCHAR(10)    NOT NULL PRIMARY KEY,
    product_name VARCHAR(100)   NOT NULL,
    category     VARCHAR(50)    NOT NULL,
    sale_price   DECIMAL(10,2)  NOT NULL,   -- <-- renamed from unit_price
    supplier_id  VARCHAR(10)    NOT NULL
        REFERENCES suppliers(supplier_id)
);


-- KNOWN QUERIES AND PIPELINES REFERENCING unit_price
-- (paste these into the prompt alongside the DDL diff)
-- =============================================================================

-- 1. order_items: unit_price_at_order compared against products.unit_price
--    in the price_matches_product DQ check

-- 2. 02_sample_queries.sql references products joined to order_items
--    (unit_price_at_order column — indirect dependency)

-- 3. customer_dim_refresh pipeline extracts unit_price from source schema
--    (this is what caused RUN0014 to fail)

-- 4. Any ad-hoc reporting query that joins products and uses unit_price
--    for revenue or margin calculations
