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
