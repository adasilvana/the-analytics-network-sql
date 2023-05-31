-- Creación de la estructura de las tablas en la base de datos dev

DROP TABLE IF EXISTS stg.cost;
    
CREATE TABLE stg.cost
                 (
                              codigo_producto    VARCHAR(10)
                            , costo_promedio_usd DECIMAL
                 );
				 
DROP TABLE IF EXISTS stg.employees;

CREATE TABLE stg.employees
(
    id_empleado serial PRIMARY KEY,
    nombre varchar(255),
    apellido varchar(255),
    fecha_entrada date,
    fecha_salida date,
    telefono varchar(255),
    pais varchar(255),
    provincia varchar(255),
    codigo_tienda smallint,
    posicion varchar(255)
);


DROP TABLE IF EXISTS stg.inventory;
    
CREATE TABLE stg.inventory
                 (
                              tienda  SMALLINT
                            , sku     VARCHAR(10)
                            , fecha   DATE
                            , inicial SMALLINT
                            , final   SMALLINT
                 );


DROP TABLE IF EXISTS stg.market_count;
    
CREATE TABLE stg.market_count
                 (
                              tienda SMALLINT
                            , fecha  INTEGER
                            , conteo SMALLINT
                 );


DROP TABLE IF EXISTS stg.monthly_average_fx_rate;
    
CREATE TABLE stg.monthly_average_fx_rate
                 (
                              mes                 DATE
                            , cotizacion_usd_peso DECIMAL
                            , cotizacion_usd_eur DECIMAL
                            , cotizacion_usd_uru  DECIMAL
                 );
				 

DROP TABLE IF EXISTS stg.order_line_sale;
    
CREATE TABLE stg.order_line_sale
                 (
                              orden      VARCHAR(10)
                            , producto   VARCHAR(10)
                            , tienda     SMALLINT
                            , fecha      date
                            , cantidad   int
                            , venta      decimal(18,5)
                            , descuento  decimal(18,5)
                            , impuestos  decimal(18,5)
                            , creditos   decimal(18,5)
                            , moneda     varchar(3)
                            , pos        SMALLINT
                            , is_walkout BOOLEAN
                 );
				 
DROP TABLE IF EXISTS stg.product_master ;
    
CREATE TABLE stg.product_master
                 (
                              codigo_producto VARCHAR(255)
                            , nombre          VARCHAR(255)
                            , categoria       VARCHAR(255)
                            , subcategoria    VARCHAR(255)
                            , subsubcategoria VARCHAR(255)
                            , material        VARCHAR(255)
                            , color           VARCHAR(255)
                            , origen          VARCHAR(255)
                            , ean             bigint
                            , is_active       boolean
                            , has_bluetooth   boolean
                            , talle           VARCHAR(255)
                 );
				 

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

DROP TABLE IF EXISTS stg.store_master;
      
CREATE TABLE stg.store_master
                 (
                              codigo_tienda  SMALLINT
                            , pais           VARCHAR(100)
                            , provincia      VARCHAR(100)
                            , ciudad         VARCHAR(100)
                            , direccion      VARCHAR(255)
                            , nombre         VARCHAR(255)
                            , tipo           VARCHAR(100)
                            , fecha_apertura DATE
                            , latitud        DECIMAL(10, 8)
                            , longitud       DECIMAL(11, 8)
                 );

DROP TABLE IF EXISTS stg.super_store_count;
    
CREATE TABLE stg.super_store_count
                 (
                              tienda SMALLINT
                            , fecha  VARCHAR(10)
                            , conteo SMALLINT
                 );
				 
DROP TABLE IF EXISTS stg.suppliers;

CREATE TABLE stg.suppliers
(
    codigo_producto varchar(255),
    nombre varchar(255),
    is_primary bool
);
