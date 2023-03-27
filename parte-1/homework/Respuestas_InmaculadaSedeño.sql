-- Homework

-- 1. Mostrar todos los productos dentro de la categoria electro junto con todos los detalles.
select *
from stg.product_master
where categoria = 'Electro'
;

-- 2. Cuales son los producto producidos en China?
select *
from stg.product_master
where origen = 'China'
;

-- 3. Mostrar todos los productos de Electro ordenados por nombre.
select *
from stg.product_master
where categoria = 'Electro'
order by nombre asc
;

-- 4. Cuales son las TV que se encuentran activas para la venta?
select *
from stg.product_master
where subcategoria = 'TV' and is_active = 'true'
;

-- 5. Mostrar todas las tiendas de Argentina ordenadas por fecha de apertura de las mas antigua a la mas nueva.
select *
from stg.store_master
where pais = 'Argentina'
order by fecha_apertura asc
;

-- 6. Cuales fueron las ultimas 5 ordenes de ventas?
select *
from stg.order_line_sale
order by fecha desc
limit 5
;

-- 7. Mostrar los primeros 10 registros del conteo de trafico por Super store ordenados por fecha.
select * 
from stg.super_store_count
limit 10
;

-- 8. Cuales son los producto de electro que no son Soporte de TV ni control remoto.
select *
from stg.product_master
where categoria = 'Electro' and subsubcategoria not in ('TV', 'Control remoto')
;

-- 9. Mostrar todas las lineas de venta donde el monto sea mayor a $100.000 solo para transacciones en pesos.
select *
from stg.order_line_sale
where venta > 100000 and moneda in ('ARS', 'URU')
;

-- 10. Mostrar todas las lineas de ventas de Octubre 2022.
select *
from stg.order_line_sale
where extract(month from fecha)='10'
;

-- 11. Mostrar todos los productos que tengan EAN.
select *
from stg.product_master
where ean is not null
;

-- 12. Mostrar todas las lineas de venta que hayan sido vendidas entre 1 de Octubre de 2022 y 10 de Noviembre de 2022.
select *
from stg.order_line_sale
where fecha between '2022-10-01' and '2022-11-10'
