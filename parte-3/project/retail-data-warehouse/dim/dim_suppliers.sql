DROP TABLE IF EXISTS dim.suppliers;

CREATE TABLE dim.suppliers
(
    id_supplier SERIAL PRIMARY KEY,
    codigo_producto varchar(255),
    nombre varchar(255),
    is_primary bool,
	
	constraint fk_tienda_id_suppliers
	foreign key (codigo_producto)
	references dim.product_master (codigo_producto)
);
