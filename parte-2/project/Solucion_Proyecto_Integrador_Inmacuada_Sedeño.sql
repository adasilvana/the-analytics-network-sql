-- *Ejercicio Integrador Parte 2*
/* Uno de los proyectos que viene trabajando nuestra empresa es de mejorar la visibilidad que le damos 
a nuestros principales KPIs que calculamos durante la Parte 1. Para eso, uno de los requisitos futuros 
va a ser crear una serie de dashboards en el cual podramos investigar cada metrica, su progresion en el 
tiempo y para diferentes cortes de los datos (Ejemplo: categoria, tienda, mes, producto, etc.). Para 
lograr esto, el primer objetivo es crear una tabla donde se pueda obtener todo esto en un mismo lugar.

Nivel de detalle de la tabla:
- Fecha
- SKU
- Tienda

Con los siguientes atributos
- Tienda: Pais, provincia, Nombre de tienda
- SKU: Categoria, Subcategoria, Subsubcategoria, proveedor
- Fecha: dia, mes, año, año fiscal, quarter fiscal

y que se pueda calcular las siguiente metricas:
- Ventas brutas
- Descuentos
- Impuestos
- Creditos
- Ventas netas (inluye ventas y descuentos)
- Valor final pagado (incluye ventas, descuentos, impuestos y creditos)
- ROI
- Days on hand
- Costos
- Margen bruto (gross margin)
- AGM (adjusted gross margin)
- AOV
- Numero de devoluciones
- Ratio de conversion.
y la posibilidad de obtener para cada una de las metricas anteriores el crecimiento mes a mes.

Notas:
No es necesario que este todo precalculado, sino que tenemos que generar una tabla lo suficientemente 
flexible para poder calcular todas las metricas listadas al nivel de de agregacion que querramos.
Tiene que ser una tabla en lugar de una vista para que pueda ser consumido rapidamente por el usuario final.
La idea que este todo en un solo lugar facilita la creacion de una sola fuenta de la verdad 
("single source of truth").
AGM es el gross margen ajustado, es decir no solo tomar los costos de los productos sino tomar otros 
gastos o descuentos que hacen los proveedores al momento de vender el producto. Al ser fijos, estos 
tienen que distribuirse en los productos vendidos de manera proporcional.
Entonces el AGM seria algo asi -> AGM: Ventas netas - Costos - Otros Gastos + Otros Ingresos
En este caso se nos pide que distribuyamos el ingreso extra de una TV dentro de los productos que se 
vendieron de Phillips. Es decir los unicos productos donde el Margen bruto va a ser distintos al AGM 
es en los productos Phillips.
El periodo fiscal de la empresa empieza el primero de febrero.
Las metricas tienen que estar calculadas en dolares. */


create table if not exists stg.tp_integrador_2 as
with precio_tele_regalada as(
	select round(avg(ventas_usd/cantidad),2) as precio_television
	from stg.ols_usd
	where producto = 'p100022'
)
, cantidad_philips as(
	select sum(case when marca = 'Philips' then 1 else 0 end) as cantidad_ordenes_philips
	from stg.ols_usd ols
	left join stg.product_master pm
	on ols.producto = pm.codigo_producto
)
select 
	td.fecha, coalesce(i.sku, ols.producto) as codigo_producto, coalesce(i.tienda, ts.tienda, ols.tienda) as codigo_tienda, -- Nivel de detalle
	sm.pais as pais_tienda, sm.provincia as provincia_tienda, sm.nombre as nombre_tienda, --Tienda
	pm.categoria as categoria_producto, pm.subcategoria as subcategoria_producto, pm.subsubcategoria as subsubcategoria_producto, s.nombre as proveedor, --SKU
	extract(day from td.fecha) as dia, td.mes, td.anno, td.anno_fiscal, td.trimestre_fiscal, -- Fecha
	ols.orden, ols.cantidad as cantidad_vendida, -- ols
	round(usd.ventas_usd,2) as ventas_brutas, round(usd.creditos_usd,2) as creditos, round(usd.descuento_usd, 2) as descuentos, round(ols.impuestos/usd.cotizacion, 2) as impuestos, -- usd
	round((i.inicial+i.final)/2, 2) as inventario_medio, co.costo_promedio_usd, -- inventario
	rv.total_cantidad as cantidad_devolucion, rv.valor_usd_devolucion as valor_devolucion, -- return
	case when pm.marca = 'Philips' and usd.ventas_usd is not null then precio_television/cantidad_ordenes_philips end as Ingresos_tele_regalada,
	ts.conteo
from stg.table_date td
full outer join stg.inventory i
on i.fecha = td.fecha
left join stg.total_store_count ts
on ts.fecha = td.fecha and ts.tienda = coalesce(i.tienda, ts.tienda)
full outer join stg.order_line_sale ols
on td.fecha = ols.fecha and ols.producto = coalesce(i.sku, ols.producto) and ols.tienda = coalesce(i.tienda, ts.tienda, ols.tienda)
left join stg.store_master sm
on sm.codigo_tienda = coalesce(i.tienda, ts.tienda, ols.tienda)
left join stg.product_master pm
on pm.codigo_producto = coalesce(i.sku, ols.producto)
left join stg.suppliers s 
on s.codigo_producto = coalesce(i.sku, ols.producto) and s.is_primary = True
left join stg.ols_usd usd
on ols.orden = usd.orden and ols.producto = usd.producto
left join stg.return_view rv
on rv.item = coalesce(ols.producto, i.sku) and rv.fecha = coalesce(ols.fecha, td.fecha)
left join stg.cost co
on co.codigo_producto = coalesce(ols.producto, i.sku)
left join precio_tele_regalada on True
left join cantidad_philips on True
where coalesce(i.sku, ols.producto) is not null or coalesce(i.tienda, ts.tienda, ols.tienda) is not null
order by td.fecha
;

select * from stg.tp_integrador_2;

-- Ventas brutas, descuentos, impuestos, creditos
select sum(ventas_brutas) as ventas_brutas, sum(descuentos) as descuentos, sum(impuestos) as impuestos, sum(creditos) as creditos
from stg.tp_integrador_2
;

-- Ventas netas 
select sum(ventas_brutas) + sum(descuentos) as ventas_netas
from stg.tp_integrador_2
;

-- Valor final pagado
select sum(ventas_brutas) + sum(descuentos) +sum(impuestos) + sum(creditos) as valor_final_pagado
from stg.tp_integrador_2
;

-- ROI
select sum(ventas_brutas)/avg(inventario_medio*costo_promedio_usd) as ROI
from stg.tp_integrador_2
;

-- Days on hand
select fecha, codigo_tienda, codigo_producto, cantidad_vendida, inventario_medio, round((avg(inventario_medio) over (partition by fecha, codigo_tienda, codigo_producto))*1.0 / (avg(cantidad_vendida) over(partition by codigo_tienda, codigo_producto order by fecha asc rows between 7 preceding and current row)*1.0), 2) as Average_days_on_hand
from stg.tp_integrador_2
where cantidad_vendida is not null and inventario_medio is not null
;

-- Costos
select 
	sum(inventario_medio*costo_promedio_usd) as costo_inventario,
	sum(cantidad_vendida*costo_promedio_usd) as costo_producto_vendido,
	sum(cantidad_devolucion*costo_promedio_usd) as costo_producto_devuelto
from stg.tp_integrador_2
;

-- Margen Bruto
select sum(ventas_brutas) + sum(descuentos) + sum(creditos) - sum(costo_promedio_usd*cantidad_vendida) as margen_bruto
from stg.tp_integrador_2
;

-- Adjusted Gross Margin (AGM)
select sum(ventas_brutas) + sum(descuentos) + sum(creditos) - sum(costo_promedio_usd*cantidad_vendida) + sum(Ingresos_tele_regalada) as AGM
from stg.tp_integrador_2
;

-- AOV (Valor promedio de la orden)
select sum(ventas_brutas)/count(orden) as AVO
from stg.tp_integrador_2
;

-- Numero de devoluciones
select count(cantidad_devolucion) as numero_devoluciones
from stg.tp_integrador_2
;

-- Ratio de conversion. Cantidad de ordenes generadas / Cantidad de gente que entra
select 
  count(orden)*10000/sum(conteo) as ratio_de_conversion_en1000porciento
from stg.tp_integrador_2
;
