-- =============================================================================
-- Course: AI for Data Management
-- Asset:  Core Schema DDL
-- Used in: Ch1 (understanding systems), Ch2 (queries), Ch3 (docs), Ch4 (reliability)
-- =============================================================================

CREATE TABLE warehouses (
    warehouse_id    VARCHAR(10)  NOT NULL PRIMARY KEY,
    warehouse_name  VARCHAR(100) NOT NULL,
    region          VARCHAR(50)  NOT NULL,
    capacity_units  INT          NOT NULL
);

CREATE TABLE suppliers (
    supplier_id     VARCHAR(10)  NOT NULL PRIMARY KEY,
    supplier_name   VARCHAR(100) NOT NULL,
    supplier_type   VARCHAR(50)  NOT NULL,   -- 'Domestic' | 'International'
    lead_time_days  INT          NOT NULL
);

CREATE TABLE products (
    product_id    VARCHAR(10)   NOT NULL PRIMARY KEY,
    product_name  VARCHAR(150)  NOT NULL,
    category      VARCHAR(50)   NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL,
    supplier_id   VARCHAR(10)   NOT NULL REFERENCES suppliers(supplier_id)
);

CREATE TABLE customers (
    customer_id          VARCHAR(10)  NOT NULL PRIMARY KEY,
    contact_name         VARCHAR(150) NOT NULL,
    region               VARCHAR(50)  NOT NULL,
    segment              VARCHAR(50)  NOT NULL,  -- 'Enterprise'|'SMB'|'Government'|'Education'
    account_created_date DATE         NOT NULL
);

CREATE TABLE orders (
    order_id     VARCHAR(10)   NOT NULL PRIMARY KEY,
    customer_id  VARCHAR(10)   NOT NULL REFERENCES customers(customer_id),
    order_date   DATE          NOT NULL,
    status       TINYINT       NOT NULL,  -- 1=Processing | 2=Shipped | 3=Completed | 4=Cancelled
    total_amount DECIMAL(10,2) NOT NULL
);

CREATE TABLE order_items (
    item_id               VARCHAR(10)   NOT NULL PRIMARY KEY,
    order_id              VARCHAR(10)   NOT NULL REFERENCES orders(order_id),
    product_id            VARCHAR(10)   NOT NULL REFERENCES products(product_id),
    quantity              INT           NOT NULL,
    unit_price_at_order   DECIMAL(10,2) NOT NULL
);

CREATE TABLE inventory (
    inventory_id     VARCHAR(10) NOT NULL PRIMARY KEY,
    product_id       VARCHAR(10) NOT NULL REFERENCES products(product_id),
    warehouse_id     VARCHAR(10) NOT NULL REFERENCES warehouses(warehouse_id),
    quantity_on_hand INT         NOT NULL,
    last_updated     DATE        NOT NULL,
    UNIQUE (product_id, warehouse_id)
);

CREATE TABLE pipeline_runs (
    run_id          VARCHAR(10)  NOT NULL PRIMARY KEY,
    pipeline_name   VARCHAR(100) NOT NULL,
    start_time      DATETIME     NOT NULL,
    end_time        DATETIME     NOT NULL,
    status          VARCHAR(20)  NOT NULL,  -- 'Success' | 'Failed'
    rows_processed  INT          NOT NULL DEFAULT 0,
    error_message   VARCHAR(500) NULL
);

CREATE TABLE data_quality_checks (
    check_id         VARCHAR(10)  NOT NULL PRIMARY KEY,
    table_name       VARCHAR(100) NOT NULL,
    check_name       VARCHAR(100) NOT NULL,
    description      VARCHAR(255) NOT NULL,
    run_date         DATE         NOT NULL,
    passed           BIT          NOT NULL,
    failed_row_count INT          NOT NULL DEFAULT 0
);

-- Downstream aggregation — populated by the sales_summary_agg pipeline,
-- which runs after daily_order_ingest completes each night.
-- Dependency chain: orders table → sales_summary_agg → daily_order_volume → morning dashboard
-- If daily_order_ingest or sales_summary_agg fails, this table will be stale or missing today's row.
CREATE TABLE daily_order_volume (
    report_date  DATE        NOT NULL PRIMARY KEY,
    order_count  INT         NOT NULL,
    day_type     VARCHAR(10) NOT NULL  -- 'weekday' | 'weekend'
);
