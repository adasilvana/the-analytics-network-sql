DROP TABLE IF EXISTS fct.return_movements;

CREATE TABLE fct.return_movements
(
    id_movimiento int PRIMARY KEY
	orden_venta varchar(255),
    envio varchar(255),
    item varchar(255),
    cantidad int,
    desde varchar(255),
    hasta varchar(255),
    recibido_por varchar(255),
    fecha date,

	-- constraint fk_orden_id_return_movements
	-- foreign key (orden_venta)
	-- references fct.order_line_sale (orden),
	
	constraint fk_item_id_return_movements
	foreign key (item)
	references dim.product_master (codigo_producto)
);
