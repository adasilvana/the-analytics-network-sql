/*  Ejercicio Integrador
Luego de un tiempo de haber respondido todas las preguntas puntuales por los gerentes, la empresa decide ampliar el contrato para mejorar las bases de reporte de datos. 
Para esto quiere definir una serie de KPIs (Key Performance Indicator) que midan la salud de la empresa en diversas areas y ademas mostrar el valor actual y la evolucion 
en el tiempo. Por cada KPI listado vamos a tener que generar al menos una query (pueden ser mas de una) que nos devuelva el valor del KPI en cada mes, mostrando el 
resultado para todos los meses disponibles.

Todos los valores monetarios deben ser calculados en dolares usando el tipo de cambio promedio mensual.

El objetivo no es solo encontrar la query que responda la metrica sino entender que datos necesitamos, que es lo que significa y como armar el KPI General 

Por otro lado tambien necesitamos crear y subir a nuestra DB la tabla "return_movements" para poder utilizarla en la segunda parte.*/

-- *KPIs General*
-- · Ventas brutas, netas y margen
select 
  extract (month from ols.fecha) as mes,
  round(sum(ols.venta/(case 
  when ols.moneda = 'ARS' then fx.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then fx.cotizacion_usd_eur
  when ols.moneda = 'URU' then fx.cotizacion_usd_uru
  end)),2) as ventas_brutas,
  round(sum((ols.venta - ols.impuestos)/(case 
  when ols.moneda = 'ARS' then fx.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then fx.cotizacion_usd_eur
  when ols.moneda = 'URU' then fx.cotizacion_usd_uru
  end)),2) as ventas_netas,
  round(sum((ols.venta + coalesce(ols.descuento, 0) + coalesce(ols.creditos, 0))/(case 
  when ols.moneda = 'ARS' then fx.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then fx.cotizacion_usd_eur
  when ols.moneda = 'URU' then fx.cotizacion_usd_uru
  end)- coalesce(cos.costo_promedio_usd, 0)),2) as margen
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate fx
on fx.mes = date(date_trunc('month', ols.fecha))
left join stg.cost cos
on ols.producto = cos.codigo_producto
group by 1
order by 1
;

-- · Margen por categoria de producto
select 
  pm.categoria,
  extract (month from ols.fecha) as mes,
  round(sum((ols.venta + coalesce(ols.descuento, 0) + coalesce(ols.creditos, 0))/(case 
  when ols.moneda = 'ARS' then fx.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then fx.cotizacion_usd_eur
  when ols.moneda = 'URU' then fx.cotizacion_usd_uru
  end)- coalesce(cos.costo_promedio_usd, 0)),2) as margen
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate fx
on fx.mes = date(date_trunc('month', ols.fecha))
left join stg.cost cos
on ols.producto = cos.codigo_producto
left join stg.product_master pm
on ols.producto = pm.codigo_producto
group by 1, 2
order by 1, 2
;

-- · ROI por categoria de producto. ROI = Valor promedio de inventario / ventas netas
select 
  pm.categoria,
  extract (month from ols.fecha) as mes,
  round(sum((inv.inicial+inv.final)/2 * coalesce(cos.costo_promedio_usd, 0))/sum((ols.venta/(case 
  when ols.moneda = 'ARS' then fx.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then fx.cotizacion_usd_eur
  when ols.moneda = 'URU' then fx.cotizacion_usd_uru
  end))), 2) as ROI
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate fx
on fx.mes = date(date_trunc('month', ols.fecha))
left join stg.cost cos
on ols.producto = cos.codigo_producto
left join stg.inventory inv
on ols.producto = inv.sku
left join stg.product_master pm
on ols.producto = pm.codigo_producto
group by 1, 2
order by 1, 2
;

-- · AOV (Average order value), valor promedio de la orden.
select 
  ols.orden,
  extract (month from ols.fecha) as mes,
  round(sum((ols.venta/ols.cantidad)/(case 
  when ols.moneda = 'ARS' then fx.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then fx.cotizacion_usd_eur
  when ols.moneda = 'URU' then fx.cotizacion_usd_uru
  end)), 2) as AOV
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate fx
on fx.mes = date(date_trunc('month', ols.fecha))
group by 1, 2
order by 1, 2
;

-- *Contabilidad*
-- · Impuestos pagados
select 
  extract (month from ols.fecha) as mes,
  round(sum(ols.impuestos/(case 
  when ols.moneda = 'ARS' then fx.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then fx.cotizacion_usd_eur
  when ols.moneda = 'URU' then fx.cotizacion_usd_uru
  end)),2) as impuestos_pagados
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate fx
on fx.mes = date(date_trunc('month', ols.fecha))
left join stg.cost cos
on ols.producto = cos.codigo_producto
group by 1
order by 1
;

-- · Tasa de impuesto. Impuestos / Ventas netas
select 
  extract (month from ols.fecha) as mes,
  round(sum(ols.impuestos)/sum(ols.venta-ols.impuestos),2) as tasa_de_impuesto
from stg.order_line_sale ols
group by 1
order by 1
;

-- · Cantidad de creditos otorgados
select 
  extract (month from ols.fecha) as mes,
  round(sum(ols.creditos/case 
  when ols.moneda = 'ARS' then fx.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then fx.cotizacion_usd_eur
  when ols.moneda = 'URU' then fx.cotizacion_usd_uru
  end),2) as creditos_otorgados
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate fx
on fx.mes = date(date_trunc('month', ols.fecha))
group by 1
order by 1
;

-- · Valor pagado final por order de linea. Valor pagado: Venta - descuento + impuesto - credito
select 
  ols.orden,
  extract (month from ols.fecha) as mes,
  round(sum((ols.venta + ols.impuestos -coalesce(ols.descuento,0) - coalesce(ols.creditos,0))/(case 
  when ols.moneda = 'ARS' then fx.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then fx.cotizacion_usd_eur
  when ols.moneda = 'URU' then fx.cotizacion_usd_uru
  end)),2) as valor_pagado
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate fx
on fx.mes = date(date_trunc('month', ols.fecha))
group by 1,2
order by 1,2
;

-- *Supply Chain*
-- · Costo de inventario promedio por tienda
select 
  inv.tienda,
  extract (month from inv.fecha) as mes,
  round(sum((inv.inicial+inv.final)/2 * coalesce(cos.costo_promedio_usd, 0)), 2) as costo_inventario
from stg.inventory inv
left join stg.cost cos
on inv.sku = cos.codigo_producto
group by 1, 2
order by 1, 2
;

-- · Costo del stock de productos que no se vendieron por tienda
select 
  inv.tienda,
  extract (month from inv.fecha) as mes,
  round(sum(inv.final * coalesce(cos.costo_promedio_usd, 0)), 2) as costo_inventario
from stg.inventory inv
left join stg.cost cos
on inv.sku = cos.codigo_producto
group by 1, 2
order by 1, 2
;

-- · Cantidad y costo de devoluciones
CREATE TABLE stg.return_movements(
	orden_venta    VARCHAR(255)
	,envio         VARCHAR(255)
	,item          VARCHAR(255)
	,cantidad      INT
	,id_movimiento INT
	,desde         VARCHAR(255)
	,hasta         VARCHAR(255)
	,recibido_por  VARCHAR(255)
	,fecha         DATE)
;
select 
  extract (month from ret.fecha) as mes,
  round(sum(ret.cantidad * coalesce(cos.costo_promedio_usd, 0)), 2) as costo_devolucion
from stg.return_movements ret
left join stg.cost cos
on ret.item = cos.codigo_producto
group by 1
order by 1
;

-- *Tiendas*
-- · Ratio de conversion. Cantidad de ordenes generadas / Cantidad de gente que entra
select 
  ols.tienda,
  extract (month from ols.fecha) as mes,
  count(ols.orden),
  sum(cou.conteo),
  count(ols.orden)*10000/sum(cou.conteo) as ratio_de_conversion_en1000porciento
from stg.order_line_sale ols
left join stg.super_store_count cou
on cou.tienda = ols.tienda
where ols.tienda <> 9
group by 1,2
order by 1,2
;



-- *Preguntas de entrevistas*
-- 1. Como encuentro duplicados en una tabla. Dar un ejemplo mostrando duplicados de la columna orden en la tabla de ventas.
select orden, count(*) 
from stg.order_line_sale
group by 1
having count(*)>1
-- Estan duplicadas ya que hay varios productos comprados dentro de una misma orden. También se podría hacer con row_number de la siguiente manera
select
  orden,
  row_number() over(
     partition by
        orden) row_num
from stg.order_line_sale
;

-- 2. Como elimino duplicados?
with duplicado as (
    select
  orden,
  row_number() over(
     partition by
        orden) row_num
from stg.order_line_sale
)
delete from duplicado
where row_num > 1;

-- 3. Cuál es la diferencia entre UNION y UNION ALL.
Ambos sirven para unir dos tablas, pero UNION une únicamente aquellas filas que no estan duplicadas entre ambas, es decir, si hay la misma fila en las dos tablas 
solo la va a coger una vez; mientras que UNION ALL va a coger todas las filas, sin importar que esten duplicadas.

-- 4. Como encuentro registros en una tabla que no estan en otra tabla. Para probar podes crear dos tablas con una unica columna id que tengan valores: Tabla 1: 1,2,3,4 Tabla 2: 3,4,5,6
Haciendo un LEFT JOIN y estableciendo una condición con where para filtrar únicamente por los valores que son nulos en la tabla dos, es decir, los que no coinciden. 
DROP TABLE IF EXISTS bkp.ejemplo1 ;
DROP TABLE IF EXISTS bkp.ejemplo2 ;
Create table bkp.ejemplo1 (id int);
Create table bkp.ejemplo2 (id int);
insert into bkp.ejemplo1 (id) values (1), (2), (3), (4);
insert into bkp.ejemplo2 (id) values (3), (4), (5), (6);
SELECT *
FROM bkp.ejemplo1 e1
left join bkp.ejemplo2 e2
on e2.id = e1.id
where e2.id is null
;

-- 6. Cual es la diferencia entre INNER JOIN y LEFT JOIN. (podes usar la tabla anterior)
El inner join me va a coger únicamente los valores que coinciden en ambas tablas, mientras que el left join va a coger todos los valores de la primera tabla y de la 
segunda solamente aquellos que coincidan.
SELECT *
FROM bkp.ejemplo1 e1
left join bkp.ejemplo2 e2
on e2.id = e1.id
;
SELECT *
FROM bkp.ejemplo1 e1
INNER join bkp.ejemplo2 e2
on e2.id = e1.id
