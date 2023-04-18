-- Homework clase 6

-- 1. Crear una vista con el resultado del ejercicio de la Parte 1 - Clase 2 - Ejercicio 10, donde unimos la cantidad de gente que ingresa a tienda usando los dos sistemas.
create or replace view stg.total_store_count as
select tienda, cast(cast(fecha as text)as date) as fecha, conteo from stg.market_count
union all
select tienda, cast(fecha as date) as fecha, conteo from stg.super_store_count
;

-- 2. Recibimos otro archivo con ingresos a tiendas de meses anteriores. Ingestar el archivo y agregarlo a la vista del ejercicio anterior (Ejercicio 1 Clase 6). Cual hubiese sido la diferencia si hubiesemos tenido una tabla? (contestar la ultima pregunta con un texto escrito en forma de comentario)
DROP TABLE IF EXISTS stg.super_store_count_september ;
CREATE TABLE stg.super_store_count_september
                 (
                              tienda   smallint
                            , fecha    date
                            , conteo   int
                 )
;
drop view if exists stg.total_store_count
;
create or replace view stg.total_store_count as
select tienda, cast(cast(fecha as text)as date) as fecha, conteo from stg.market_count
union all
select tienda, cast(fecha as date) as fecha, conteo from stg.super_store_count
union all
select tienda, cast(fecha as date) as fecha, conteo from stg.super_store_count_september
order by tienda, fecha
;

-- 3. Crear una vista con el resultado del ejercicio de la Parte 1 - Clase 3 - Ejercicio 10, donde calculamos el margen bruto en dolares. Agregarle la columna de ventas, descuentos, y creditos en dolares para poder reutilizarla en un futuro.
create or replace view stg.ols_margen_usd as
with cotizacion_usd as
(select 
  ols.orden,
  ols.producto,
  case 
  when ols.moneda = 'ARS' then ma.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then ma.cotizacion_usd_eur
  when ols.moneda = 'URU' then ma.cotizacion_usd_uru
  end as cotizacion
 from stg.order_line_sale ols
left join stg.monthly_average_fx_rate ma
on extract(month from ols.fecha) = extract(month from ma.mes) and extract(year from ols.fecha) = extract(year from ma.mes)
)
select
  ols.orden,
  ols.producto,
  ols.venta/cot.cotizacion as ventas_usd, 
  ols.creditos/cot.cotizacion as creditos_usd, 
  ols.descuento/cot.cotizacion as descuento_usd, 
  round((ols.venta - coalesce(ols.descuento, 0))/cot.cotizacion - coalesce(cos.costo_promedio_usd, 0),2) as margen_usd
from stg.order_line_sale ols
left join cotizacion_usd cot
on ols.orden = cot.orden and ols.producto = cot.producto
left join stg.cost cos
on ols.producto = cos.codigo_producto
;

-- 4. Generar una query que me sirva para verificar que el nivel de agregacion de la tabla de ventas (y de la vista) no se haya afectado. Recordas que es el nivel de agregacion/detalle? Lo vimos en la teoria de la parte 1! Nota: La orden M999000061 parece tener un problema verdad? Lo vamos a solucionar mas adelante.
select orden, producto, count(1) as count_ols
from stg.order_line_sale
group by 1, 2
having count(1)>1
;
select orden, producto, count(1) as count_margen
from stg.ols_margen_usd
group by 1, 2
having count(1)>1
;

-- 5. Calcular el margen bruto a nivel Subcategoria de producto. Usar la vista creada.
select pm.subcategoria, sum(mar.margen_usd) as margen_bruto
from stg.ols_margen_usd mar
left join stg.product_master pm
on mar.producto=pm.codigo_producto
group by 1
;

-- 6. Calcular la contribucion de las ventas brutas de cada producto al total de la orden. Por esta vez, si necesitas usar una subquery, podes utilizarla.
with ventas_orden as (
select orden, sum(ventas_usd) as total_orden
from stg.ols_margen_usd
group by 1)
select mar.orden, mar.producto, round(sum(mar.ventas_usd/vo.total_orden),2)
from stg.ols_margen_usd mar
left join ventas_orden vo
on mar.orden = vo.orden
group by 1,2
order by 1,2
;

-- 7. Calcular las ventas por proveedor, para eso cargar la tabla de proveedores por producto. Agregar el nombre el proveedor en la vista del punto 3.
DROP TABLE IF EXISTS stg.suppliers ;
CREATE TABLE stg.suppliers
                 (
                              codigo_producto   VARCHAR(255)
                            , nombre            VARCHAR(255)
                            , is_primary        boolean
                 )
;
drop view if exists stg.ols_margen_usd
;
create or replace view stg.ols_margen_usd as
with cotizacion_usd as
(select 
  ols.orden,
  ols.producto,
  case 
  when ols.moneda = 'ARS' then ma.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then ma.cotizacion_usd_eur
  when ols.moneda = 'URU' then ma.cotizacion_usd_uru
  end as cotizacion
 from stg.order_line_sale ols
left join stg.monthly_average_fx_rate ma
on extract(month from ols.fecha) = extract(month from ma.mes) and extract(year from ols.fecha) = extract(year from ma.mes)
)
select
  ols.orden,
  ols.producto,
  sup.nombre,
  ols.venta/cot.cotizacion as ventas_usd, 
  ols.creditos/cot.cotizacion as creditos_usd, 
  ols.descuento/cot.cotizacion as descuento_usd, 
  round((ols.venta - coalesce(ols.descuento, 0))/cot.cotizacion - coalesce(cos.costo_promedio_usd, 0),2) as margen_usd
from stg.order_line_sale ols
left join cotizacion_usd cot
on ols.orden = cot.orden and ols.producto = cot.producto
left join stg.cost cos
on ols.producto = cos.codigo_producto
left join stg.suppliers sup
on ols.producto = sup.codigo_producto
;

-- 8. Verificar que el nivel de detalle de la vista anterior no se haya modificado, en caso contrario que se deberia ajustar? Que decision tomarias para que no se genereren duplicados?
-- · Se pide correr la query de validacion.
select orden, producto, count(1) as count_ols
from stg.order_line_sale
group by 1, 2
having count(1)>1
;
select orden, producto, count(1) as count_margen
from stg.ols_margen_usd
group by 1, 2
having count(1)>1 
-- Se han generado duplicados al introducir los proveedores
-- El error se debe a que hay varios provedores para un mismo producto, por lo que hemos de coger únicamente el primario
;

-- · Crear una nueva query que no genere duplicacion.
create or replace view stg.ols_margen_usd as
with cotizacion_usd as
(select 
  ols.orden,
  ols.producto,
  case 
  when ols.moneda = 'ARS' then ma.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then ma.cotizacion_usd_eur
  when ols.moneda = 'URU' then ma.cotizacion_usd_uru
  end as cotizacion
 from stg.order_line_sale ols
left join stg.monthly_average_fx_rate ma
on extract(month from ols.fecha) = extract(month from ma.mes) and extract(year from ols.fecha) = extract(year from ma.mes)
)
select
  ols.orden,
  ols.producto,
  sup.nombre,
  ols.venta/cot.cotizacion as ventas_usd, 
  ols.creditos/cot.cotizacion as creditos_usd, 
  ols.descuento/cot.cotizacion as descuento_usd, 
  round((ols.venta - coalesce(ols.descuento, 0))/cot.cotizacion - coalesce(cos.costo_promedio_usd, 0),2) as margen_usd
from stg.order_line_sale ols
left join cotizacion_usd cot
on ols.orden = cot.orden and ols.producto = cot.producto
left join stg.cost cos
on ols.producto = cos.codigo_producto
left join stg.suppliers sup
on ols.producto = sup.codigo_producto
where sup.is_primary = true
;

-- · Explicar brevemente (con palabras escrito tipo comentario) que es lo que sucedia.
El error se debía a que hay varios provedores para un mismo producto, por lo que hemos de coger únicamente el primario a fin de no crear duplicados.
El único error que seguimos manteniendo es el de la orden M999000061
