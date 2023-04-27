-- *Homework clase 6*

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



-- *Homework clase 7*

-- 1. Calcular el porcentaje de valores null de la tabla stg.order_line_sale para la columna creditos y descuentos. (porcentaje de nulls en cada columna)
select
  round(sum(case when creditos is null then 1 else 0 end)* 1.0 / (count(orden)*1.0) *100 ,2) as porcentaje_nulos_creditos,
  round(sum(case when descuento is null then 1 else 0 end)* 1.0 / (count(orden)*1.0) *100, 2) as porcentaje_nulos_descuentos
from stg.order_line_sale
;

-- 2. La columna "is_walkout" se refiere a los clientes que llegaron a la tienda y se fueron con el producto en la mano (es decir habia stock disponible). Responder en una misma query:
-- a) Cuantas ordenes fueron "walkout" por tienda?
-- b) Cuantas ventas brutas en USD fueron "walkout" por tienda?
-- c) Cual es el porcentaje de las ventas brutas "walkout" sobre el total de ventas brutas por tienda?
select
  ols.tienda,
  sum(case when is_walkout = True then 1 else 0 end) as walkout_por_tienda,
  round(sum(case when is_walkout = True then venta else 0 end/(case 
  when ols.moneda = 'ARS' then fx.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then fx.cotizacion_usd_eur
  when ols.moneda = 'URU' then fx.cotizacion_usd_uru
  end)), 2) as ventas_walkout_por_tienda, 
  round(sum(case when is_walkout = True then venta else 0 end) * 1.0 / (sum(venta)*1.0) *100 ,2) as porcentaje_ventas_walkout_por_tienda
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate
on fx.mes = date(date_trunc('month', ols.fecha))
group by tienda
;

-- 3. Siguiendo el nivel de detalle de la tabla ventas, hay una orden que no parece cumplirlo. Como identificarias duplicados utilizando una windows function? Nota: Esto hace referencia a la orden M999000061. Tenes que generar una forma de excluir los casos duplicados, para este caso particular y a nivel general, si llegan mas ordenes con duplicaciones.
-- Para ver los duplicados
with cte as(
select
  orden, producto,
  row_number() over(partition by orden, producto) as rn
  from stg.order_line_sale
)
select * from cte
where rn > 1
;
-- Para eliminarlos
with cte as(
select
  orden, producto,
  row_number() over(partition by orden, producto) as rn
  from stg.order_line_sale
)
delete * from cte
where rn > 1
;

-- 4. Obtener las ventas totales en USD de productos que NO sean de la categoria "TV" NI esten en tiendas de Argentina.
select
  sum(ols.venta/(case 
  when ols.moneda = 'ARS' then fx.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then fx.cotizacion_usd_eur
  when ols.moneda = 'URU' then fx.cotizacion_usd_uru
  end)) as Ventas_totales_USD
from stg.order_line_sale ols
left join stg.product_master pm
on ols.producto = pm.codigo_producto
left join stg.monthly_average_fx_rate fx
on fx.mes = date(date_trunc('month', ols.fecha))
left join stg.store_master sm
on ols.tienda = sm.codigo_tienda
where pm.subcategoria <> 'TV' and sm.pais <> 'Argentina'
;

-- 5. El gerente de ventas quiere ver el total de unidades vendidas por dia junto con otra columna con la cantidad de unidades vendidas una semana atras y la diferencia entre ambos. Nota: resolver en dos querys usando en una CTEs y en la otra windows functions.
with suma as (select fecha, sum(cantidad) as unidades_vendidas
from stg.order_line_sale
group by 1
order by 1)
select fecha, 
	unidades_vendidas, 
	lag(unidades_vendidas, 7) over (order by fecha) as unidades_vendidas_una_semana_atras, 
	abs(unidades_vendidas - lag(unidades_vendidas, 7) over (order by fecha)) as diferencia 
from suma
;

-- 6. Crear una vista de inventario con la cantidad de inventario por dia, tienda y producto, que ademas va a contar con los siguientes datos:
-- · Nombre y categorias de producto
-- · Pais y nombre de tienda
-- · Costo del inventario por linea (recordar que si la linea dice 4 unidades debe reflejar el costo total de esas 4 unidades)
-- · Una columna llamada "is_last_snapshot" para el ultimo dia disponible de inventario.
-- · Ademas vamos a querer calcular una metrica llamada "Average days on hand (DOH)" que mide cuantos dias de venta nos alcanza el inventario. Para eso DOH = Unidades en Inventario Promedio / Promedio diario Unidades vendidas ultimos 7 dias.
-- · Notas:
--      * Antes de crear la columna DOH, conviene crear una columna que refleje el Promedio diario Unidades vendidas ultimos 7 dias.
--      * El nivel de agregacion es dia/tienda/sku.
--      * El Promedio diario Unidades vendidas ultimos 7 dias tiene que calcularse para cada dia.
create or replace view stg.inventary_dia_tienda_producto as
select 
	i.fecha,
	i.tienda,
	i.sku,
	avg((i.inicial+i.final)/2) over (partition by i.fecha, i.tienda, i.sku) as inventario,
	pm.nombre as nombre_producto, 
	pm.categoria, 
	sm.pais, 
	sm.nombre as nombre_tienda, 
	avg((i.inicial+i.final)/2) over (partition by i.fecha, i.tienda, i.sku) * cos.costo_promedio_usd as coste_inventario,
	case when lead(i.fecha) over (partition by i.tienda, i.sku) is null then 1 else 0 end as is_last_snapshot,
	ols.venta,
	avg((i.inicial+i.final)/2) over (partition by i.fecha, i.tienda, i.sku) as promedio_inventario,
	avg(ols.cantidad) over(partition by ols.tienda, ols.producto order by ols.fecha asc rows between 7 preceding and current row) as Promedio_diario_unidades_vendidas_7_dias,
	round((avg((i.inicial+i.final)/2) over (partition by i.fecha, i.tienda, i.sku))*1.0 / (avg(ols.cantidad) over(partition by ols.tienda, ols.producto order by ols.fecha asc rows between 7 preceding and current row)*1.0), 2) as Average_days_on_hand
from stg.inventory i
left join stg.product_master pm
on pm.codigo_producto = i.sku
left join stg.store_master sm
on sm.codigo_tienda = i.tienda
left join stg.cost cos
on cos.codigo_producto = i.sku
left join stg.order_line_sale ols
on ols.fecha = i.fecha and ols.producto = i.sku and ols.tienda = i.tienda
;



-- *Homework clase 8*

-- Clase 8
-- 1. Realizar el Ejercicio 5 (creo que es el 6) de la clase 6 donde calculabamos la contribucion de las ventas brutas de cada producto utilizando una window function.
select ols.orden, ols.producto, venta,
		round(venta/sum(venta) over (partition by ols.orden), 4) as contribucion_ventas_productos
from stg.order_line_sale ols
order by 1
;

-- 2. La regla de pareto nos dice que aproximadamente un 20% de los productos generan un 80% de las ventas. Armar una vista a nivel sku donde se pueda identificar por orden de contribucion, ese 20% aproximado de SKU mas importantes. (Nota: En este ejercicios estamos construyendo una tabla que muestra la regla de Pareto)
with ventas_mes as (
select
    producto,
    sum(round(ols.venta/(case 
    when moneda = 'EUR' then mfx.cotizacion_usd_eur
    when moneda = 'ARS' then mfx.cotizacion_usd_peso
    when moneda = 'URU' then mfx.cotizacion_usd_uru
    else 0 end),1)) as venta_bruta_usd
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate mfx 
	on extract(month from mfx.mes) = extract(month from ols.fecha) 
	and extract(year from mfx.mes) = extract(year from ols.fecha) 
    group by 1
) 
, total_ventas as(
	select sum(venta_bruta_usd) as ventas_totales
    from ventas_mes)
, total_productos as(
    select count(producto) as productos_totales
    from ventas_mes)
select producto, 
	venta_bruta_usd, 
	sum(venta_bruta_usd) over(order by venta_bruta_usd desc) as ventas_acumuladas, 
	ventas_totales, 
	productos_totales, 
	round(sum(venta_bruta_usd) over(order by venta_bruta_usd desc) / ventas_totales * 100,2) as porcentaje_ventas_acumuladas, 
	round(count(producto) over(order by venta_bruta_usd desc)*1.0 / productos_totales*1.0 * 100,2) as porcentaje_productos_acumulados
from ventas_mes, total_ventas, total_productos
;
-- Vemos que un 44% de los productos contribuyen a un 81% de las ventas. Los productos que más contribuyen de mayor a menor contribución son: "p100022", "p100014", "p200089", y "p200087".

-- 3. Calcular el crecimiento de ventas por tienda mes a mes, con el valor nominal y el valor % de crecimiento.
with total_mes_tienda as(
select ols.tienda, extract(month from fecha) as mes, sum(venta) as total
from stg.order_line_sale ols
group by 1, 2
order by 1, 2)
select tmt.tienda, tmt.mes, total,
		round(total - lag(total) over (partition by tmt.tienda order by tmt.mes), 2) as incremento_nominal,
		round((total - lag(total) over (partition by tmt.tienda order by tmt.mes))/ total  *100, 2) as incremento_porcentual
from total_mes_tienda tmt
;

-- 4. Crear una vista a partir de la tabla "return_movements" que este a nivel Orden de venta, item y que contenga las siguientes columnas:
-- Orden
-- Sku 
-- Cantidad unidated retornadas
-- Valor USD retornado (resulta de la cantidad retornada * valor USD del precio unitario bruto con que se hizo la venta)
-- Nombre producto
-- Primera_locacion (primer lugar registrado, de la columna "desde", para la orden/producto)
-- Ultima_locacion (el ultimo lugar donde se registro, de la columna "hasta", el producto/orden)
create or replace view stg.return_view as
with cantidad_item_orden as(
select orden_venta,
	   item,
	   sum(cantidad) as total_cantidad
from stg.return_movements rm
group by 1,2
order by 1,2)
select distinct cio.orden_venta,
	   cio.item,
	   total_cantidad,
	   (total_cantidad * ols.venta / ols.cantidad)/(case 
    		when ols.moneda = 'EUR' then mfx.cotizacion_usd_eur
    		when ols.moneda = 'ARS' then mfx.cotizacion_usd_peso
    		when ols.moneda = 'URU' then mfx.cotizacion_usd_uru
    		else 0 end) as valor_usd_devolucion,
	   pm.nombre,
	   first_value(rm.desde) over(partition by cio.orden_venta, cio.item order by rm.id_movimiento rows between unbounded preceding and unbounded following) as Primera_location,
	   last_value(rm.hasta) over(partition by cio.orden_venta, cio.item order by rm.id_movimiento rows between unbounded preceding and unbounded following) as Ultima_location
from cantidad_item_orden cio
left join stg.return_movements rm
	on cio.orden_venta = rm.orden_venta and cio.item = rm.item
left join stg.product_master pm
	on rm.item = pm.codigo_producto
left join stg.order_line_sale ols
	on ols.orden = cio.orden_venta and ols.producto = cio.item
left join stg.monthly_average_fx_rate mfx 
	on extract(month from mfx.mes) = extract(month from ols.fecha) 
	and extract(year from mfx.mes) = extract(year from ols.fecha)
;

-- 5. Crear una tabla calendario llamada "date" con las fechas del 2022 incluyendo el año fiscal y trimestre fiscal (en ingles Quarter). El año fiscal de la empresa comienza el primero Febrero de cada año y dura 12 meses. Realizar la tabla para 2022 y 2023. La tabla debe contener:
-- Fecha (date)
-- Mes (date)
-- Año (date)
-- Dia de la semana (text, ejemplo: "Monday")
-- "is_weekend" (boolean, indicando si es Sabado o Domingo)
-- Mes (text, ejemplo: June)
-- Año fiscal (date)
-- Año fiscal (text, ejemplo: "FY2022")
-- Trimestre fiscal (text, ejemplo: Q1)
-- Fecha del año anterior (date, ejemplo: 2021-01-01 para la fecha 2022-01-01)
-- Nota: En general una tabla date es creada para muchos años mas (minimo 10), por el momento nos ahorramos ese paso y de la creacion de feriados.
create table stg.table_date as (
with base_fecha as(
	select cast('2022-01-01' as date) + (n || 'day')::interval as fecha
	from generate_series(0,365) n)
select
	to_char(fecha, 'yyyymmdd')::INT as fecha_id,
	cast(fecha as date) as fecha,
	extract(month from fecha) as mes,
	extract(year from fecha) as anno,
	to_char(fecha, 'Day') AS dia_semana,
	case when extract(dow from fecha) in (0,6) then True 
		 else False end as is_weekend,
	to_char(fecha, 'Month') AS nombre_mes,
	case when extract(month from fecha) < 2 then extract(year from fecha) - 1 
	     else extract(year from fecha) end as anno_fiscal,
	concat('FY', cast (case when extract(month from fecha) < 2 then extract(year from fecha) - 1 
					        else extract(year from fecha) end as text)) as nombre_anno_fiscal,
	case when extract(month from fecha) in (2,3,4) then 'Q1' 
	     when extract(month from fecha) in (5,6,7) then 'Q2' 
		 when extract(month from fecha) in (8,9,10) then 'Q3' 
		 else 'Q4' end as trimestre_fiscal,
	cast(fecha - interval'1 year' as date) as fecha_anno_anterior
from base_fecha)
; 
