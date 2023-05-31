DROP TABLE IF EXISTS dim.employees;

CREATE TABLE dim.employees
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
    posicion varchar(255),
    is_active boolean,
    duracion_empleado decimal,
	
    constraint fk_tienda_id_employees
    foreign key (codigo_tienda)
    references dim.store_master (codigo_tienda)
);
