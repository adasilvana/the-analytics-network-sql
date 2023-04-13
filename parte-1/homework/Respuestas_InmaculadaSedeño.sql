-- Homework clase 1

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
where categoria = 'Electro' and subsubcategoria not in ('Soporte', 'Control remoto')
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



-- Homework clase 2

-- 1. Cuales son los paises donde la empresa tiene tiendas?
select distinct pais
from stg.store_master
;

-- 2. Cuantos productos por subcategoria tiene disponible para la venta?
select subcategoria, count(distinct codigo_producto) as numero_de_productos
from stg.product_master
group by 1
order by 2 desc
;

-- 3. Cuales son las ordenes de venta de Argentina de mayor a $100.000?
select *
from stg.order_line_sale
where moneda = 'ARS' and venta > 100000
;

-- 4. Obtener los descuentos otorgados durante Noviembre de 2022 en cada una de las monedas?
select moneda, sum(descuento)
from stg.order_line_sale
where extract(month from fecha)=11
group by 1
order by 2 desc
;

-- 5. Obtener los impuestos pagados en Europa durante el 2022.
select sum(impuestos)
from stg.order_line_sale
where extract(year from fecha)=2022 and moneda='EUR'
;

-- 6. En cuantas ordenes se utilizaron creditos?
select count(orden)
from stg.order_line_sale
where creditos is not null
;

-- 7. Cual es el % de descuentos otorgados (sobre las ventas) por tienda?
select tienda, round(sum(descuento)/sum(venta)*-100,2) as porcentaje_descuentos_otorgados
from stg.order_line_sale
group by 1
;

-- 8. Cual es el inventario promedio por dia que tiene cada tienda?
select tienda, fecha, (sum(inicial)+sum(final))/2 as inventario_medio_total
from stg.inventory
group by 1,2
order by 1,2
;

-- 9. Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina.
select producto, sum(venta - impuestos) as ventas_netas, sum(descuento)/sum(venta)*100 as porcentaje_descuentos_otorgados
from stg.order_line_sale
where moneda = 'ARS'
group by 1
order by 2 desc
;

-- 10. Las tablas "market_count" y "super_store_count" representan dos sistemas distintos que usa la empresa para contar la cantidad de gente que ingresa a tienda, uno para las tiendas de Latinoamerica y otro para Europa. Obtener en una unica tabla, las entradas a tienda de ambos sistemas.
select tienda, cast(cast(fecha as text) as date), conteo from stg.market_count
union all
select tienda, cast(fecha as date), conteo from stg.super_store_count
;

-- 11. Cuales son los productos disponibles para la venta (activos) de la marca Phillips?
select *
from stg.product_master
where upper(nombre) like '%PHILIPS%' and is_active = 'true'
;

-- 12. Obtener el monto vendido por tienda y moneda y ordenarlo de mayor a menor por valor nominal.
select tienda, moneda, sum(venta) as monto_vendido
from stg.order_line_sale
group by 1, 2
order by 3 desc
;

-- 13. Cual es el precio promedio de venta de cada producto en las distintas monedas? Recorda que los valores de venta, impuesto, descuentos y creditos es por el total de la linea.
select producto, moneda, round(sum(venta)/sum(cantidad),2) as precio_promedio
from stg.order_line_sale
group by 1, 2
order by 1, 2
;

-- 14. Cual es la tasa de impuestos que se pago por cada orden de venta?
select orden, round(sum(impuestos)/sum(venta)*100,2)
from stg.order_line_sale
group by 1
;



-- Homework clase 3

-- 1. Mostrar nombre y codigo de producto, categoria y color para todos los productos de la marca Philips y Samsung, mostrando la leyenda "Unknown" cuando no hay un color disponible
select nombre, codigo_producto, categoria, coalesce(color,'Unknown') as color
from stg.product_master
where upper(nombre) like '%PHILIPS%' OR upper(nombre) like '%SAMSUNG%'
;

-- 2. Calcular las ventas brutas y los impuestos pagados por pais y provincia en la moneda correspondiente.
select sm.pais, sm.provincia, ols.moneda, sum(ols.venta) as ventas_brutas, sum(ols.impuestos) as impuestos_pagados
from stg.order_line_sale ols
left join stg.store_master sm
on ols.tienda = sm.codigo_tienda
group by 1, 2, 3
;

-- 3. Calcular las ventas totales por subcategoria de producto para cada moneda ordenados por subcategoria y moneda.
select pm.subcategoria, ols.moneda, sum(ols.venta) as ventas_totales
from stg.order_line_sale ols
left join stg.product_master pm
on ols.producto = pm.codigo_producto
group by 1, 2
order by 1, 2
;

-- 4. Calcular las unidades vendidas por subcategoria de producto y la concatenacion de pais, provincia; usar guion como separador y usarla para ordernar el resultado.
select 
  pm.subcategoria, 
  sm.pais || '-' || sm.provincia as pais_provincia, 
  sum(ols.cantidad) as unidades_vendidas
from stg.order_line_sale ols
left join stg.product_master pm
on ols.producto = pm.codigo_producto
left join stg.store_master sm
on ols.tienda = sm.codigo_tienda
group by 1, 2
order by 2
;

-- 5. Mostrar una vista donde sea vea el nombre de tienda y la cantidad de entradas de personas que hubo desde la fecha de apertura para el sistema "super_store".
select tienda, sum(conteo) as conteo
from stg.super_store_count
group by 1
;

-- 6. Cual es el nivel de inventario promedio en cada mes a nivel de codigo de producto y tienda; mostrar el resultado con el nombre de la tienda.
select sku, tienda, extract(month from fecha) as mes, sum((inicial+final)/2) as inventario_medio_total
from stg.inventory
group by 1, 2, 3
;

-- 7. Calcular la cantidad de unidades vendidas por material. Para los productos que no tengan material usar 'Unknown', homogeneizar los textos si es necesario.
select upper(coalesce(pm.material, 'Unknown')) as material, sum(ols.cantidad) as cantidad_total
from stg.order_line_sale ols
left join stg.product_master pm
on ols.producto = pm.codigo_producto
group by 1
order by 1
;

-- 8. Mostrar la tabla order_line_sales agregando una columna que represente el valor de venta bruta en cada linea convertido a dolares usando la tabla de tipo de cambio.
select ols.*,
  case when ols.moneda = 'ARS' then ols.venta/ma.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then ols.venta/ma.cotizacion_usd_eur
  when ols.moneda = 'URU' then ols.venta/ma.cotizacion_usd_uru
  end as ventas_usd
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate ma
on extract(month from ols.fecha) = extract(month from ma.mes) and extract(year from ols.fecha) = extract(year from ma.mes)
;

-- 9. Calcular cantidad de ventas totales de la empresa en dolares.
select
  round(sum(ols.venta/(case when ols.moneda = 'ARS' then ma.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then ma.cotizacion_usd_eur
  when ols.moneda = 'URU' then ma.cotizacion_usd_uru
  end)),2) as ventas_usd_totales
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate ma
on extract(month from ols.fecha) = extract(month from ma.mes) and extract(year from ols.fecha) = extract(year from ma.mes)
;

-- 10. Mostrar en la tabla de ventas el margen de venta por cada linea. Siendo margen = (venta - promociones) - costo expresado en dolares.
select
  ols.*, round((ols.venta - coalesce(ols.descuento, 0))/(case 
  when ols.moneda = 'ARS' then ma.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then ma.cotizacion_usd_eur
  when ols.moneda = 'URU' then ma.cotizacion_usd_uru
  end) - coalesce(cos.costo_promedio_usd, 0),2) as margen
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate ma
on extract(month from ols.fecha) = extract(month from ma.mes) and extract(year from ols.fecha) = extract(year from ma.mes)
left join stg.cost cos
on ols.producto = cos.codigo_producto
;

-- 11. Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.
select pm.subsubcategoria, ols.orden, count(distinct(ols.producto)) as items_distintos
from stg.order_line_sale ols
left join stg.product_master pm
on ols.producto = pm.codigo_producto
group by 1, 2									
;

-- Homework clase 4

-- 1. Crear un backup de la tabla product_master. Utilizar un esquema llamada "bkp" y agregar un prefijo al nombre de la tabla con la fecha del backup en forma de numero entero.
create schema bkp
;
select *
into bkp.product_master_20220410
from stg.product_master

-- 2. Hacer un update a la nueva tabla (creada en el punto anterior) de product_master agregando la leyendo "N/A" para los valores null de material y color. Pueden utilizarse dos sentencias.
update bkp.product_master_20220410 set material = 'N/A' where material is null
;
update bkp.product_master_20220410 set color = 'N/A' where color is null

-- 3. Hacer un update a la tabla del punto anterior, actualizando la columa "is_active", desactivando todos los productos en la subsubcategoria "Control Remoto".
update bkp.product_master_20220410 set is_active = false where subsubcategoria = 'Control remoto'

-- 4. Agregar una nueva columna a la tabla anterior llamada "is_local" indicando los productos producidos en Argentina y fuera de Argentina.
alter table bkp.product_master_20220410
add column is_local boolean
;
update bkp.product_master_20220410 set is_local = case when origen = 'Argentina' then true else false end

-- 5. Agregar una nueva columna a la tabla de ventas llamada "line_key" que resulte ser la concatenacion de el numero de orden y el codigo de producto.
alter table stg.order_line_sale
add column line_key varchar(255)
;
update stg.order_line_sale set line_key = orden || '-' || producto 

-- 6. Eliminar todos los valores de la tabla "order_line_sale" para el POS 1.
delete from stg.order_line_sale where pos = 1

-- 7. Crear una tabla llamada "employees" (por el momento vacia) que tenga un id (creado de forma incremental), nombre, apellido, fecha de entrada, fecha salida, telefono, pais, provincia, codigo_tienda, posicion. Decidir cual es el tipo de dato mas acorde.
DROP TABLE IF EXISTS bkp.employees ;
CREATE TABLE bkp.employees
                 (
                              id_empleado     serial primary key
                            , nombre          VARCHAR(255)
                            , apellido        VARCHAR(255)
                            , fecha_entrada   DATE
                            , fecha_salida    DATE
                            , telefono        VARCHAR(255)
                            , pais            VARCHAR(255)
                            , provincia       VARCHAR(255)
                            , codigo_tienda   smallint
                            , posicion        VARCHAR(255)
                 )
;
select *
from bkp.employees
;

-- 8. Insertar nuevos valores a la tabla "employees" para los siguientes 4 empleados:
-- · Juan Perez, 2022-01-01, telefono +541113869867, Argentina, Santa Fe, tienda 2, Vendedor.
-- · Catalina Garcia, 2022-03-01, Argentina, Buenos Aires, tienda 2, Representante Comercial
-- · Ana Valdez, desde 2020-02-21 hasta 2022-03-01, España, Madrid, tienda 8, Jefe Logistica
-- · Fernando Moralez, 2022-04-04, España, Valencia, tienda 9, Vendedor.
insert into bkp.employees (nombre, apellido, fecha_entrada, fecha_salida, telefono, pais, provincia, codigo_tienda, posicion)
values ('Juan', 'Perez', '2022-01-01', null, '+541113869867', 'Argentina', 'Santa Fe', 2, 'Vendedor'),
       ('Catalina', 'Garcia', '2022-03-01', null, null, 'Argentina', 'Buenos Aires', 2, 'Representante Comercial'),
	   ('Ana', 'Valdez', '2020-02-21', '2022-03-01', null, 'España', 'Madrid', 8, 'Jefe Logistica'),
	   ('Fernando', 'Moralez', '2022-04-04', null, null, 'España', 'Valencia', 9, 'Vendedor')
;

-- 9. Crear un backup de la tabla "cost" agregandole una columna que se llame "last_updated_ts" que sea el momento exacto en el cual estemos realizando el backup en formato datetime.
select *, current_timestamp as backup_date
into bkp.cost_20220410
from stg.cost
;
select *
from bkp.cost_20220410
;

-- 10. El cambio en la tabla "order_line_sale" en el punto 6 fue un error y debemos volver la tabla a su estado original, como lo harias?
Por lo que he podido averiguar, podríamos hacer un restore escogiendo un momento del tiempo previo al cambio erroneo que hemos realizado, o podríamos usar un insert into para introducir de nuevo los datos manualmente.
