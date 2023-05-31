DROP TABLE IF EXISTS stg.return_movements;

CREATE TABLE stg.return_movements
(
    orden_venta varchar(255),
    envio varchar(255),
    item varchar(255),
    cantidad int,
    id_movimiento int,
    desde varchar(255),
    hasta varchar(255),
    recibido_por varchar(255),
    fecha date
);
