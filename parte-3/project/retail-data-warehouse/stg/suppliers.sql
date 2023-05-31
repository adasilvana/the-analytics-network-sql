DROP TABLE IF EXISTS stg.suppliers;

CREATE TABLE stg.suppliers
(
    codigo_producto varchar(255),
    nombre varchar(255),
    is_primary bool
)
