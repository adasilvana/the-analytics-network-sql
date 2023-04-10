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
where extract(month from fecha)=10
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
select tienda, avg(descuento/venta*100) as porcentaje_descuentos_otorgados
from stg.order_line_sale
group by 1
order by 2 desc
;

-- 8. Cual es el inventario promedio por dia que tiene cada tienda?
select tienda, fecha, sum((inicial+final)/2) as inventario_medio_total
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
select tienda, cast(fecha as varchar(10)) as fecha, conteo from stg.market_count
union all
select tienda, cast(fecha as varchar(10)) as fecha, conteo from stg.super_store_count
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
select *,
  case when ols.moneda = 'ARS' then ols.venta * ma.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then ols.venta * ma.cotizacion_usd_eur
  when ols.moneda = 'URU' then ols.venta * ma.cotizacion_usd_uru
  end as ventas_usd
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate ma
on extract(month from ols.fecha) = extract(month from ma.mes) and extract(year from ols.fecha) = extract(year from ma.mes)
;

-- 9. Calcular cantidad de ventas totales de la empresa en dolares.
with usd as(
select
  case when ols.moneda = 'ARS' then ols.venta * ma.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then ols.venta * ma.cotizacion_usd_eur
  when ols.moneda = 'URU' then ols.venta * ma.cotizacion_usd_uru
  end as ventas_usd
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate ma
on extract(month from ols.fecha) = extract(month from ma.mes) and extract(year from ols.fecha) = extract(year from ma.mes))
select round(sum(ventas_usd),2) as ventas_totales_usd from ventas_usd
;

-- 10. Mostrar en la tabla de ventas el margen de venta por cada linea. Siendo margen = (venta - promociones) - costo expresado en dolares.
with usd as(
select
  *,
  case when ols.moneda = 'ARS' then ols.venta * ma.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then ols.venta * ma.cotizacion_usd_eur
  when ols.moneda = 'URU' then ols.venta * ma.cotizacion_usd_uru
  end as ventas_usd,
  case when ols.moneda = 'ARS' then ols.descuento * ma.cotizacion_usd_peso 
  when ols.moneda = 'EUR' then ols.descuento * ma.cotizacion_usd_eur
  when ols.moneda = 'URU' then ols.descuento * ma.cotizacion_usd_uru
  end as descuento_usd
from stg.order_line_sale ols
left join stg.monthly_average_fx_rate ma
on extract(month from ols.fecha) = extract(month from ma.mes) and extract(year from ols.fecha) = extract(year from ma.mes))
select usd.orden, (usd.ventas_usd - coalesce(usd.descuento_usd, 0)) - coalesce(costo_promedio_usd, 0) as margen
from usd usd
left join stg.cost cos
on usd.producto = cos.codigo_producto
;

-- 11. Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.
select pm.subsubcategoria, ols.orden, count(distinct(ols.producto)) as items_distintos
from stg.order_line_sale ols
left join stg.product_master pm
on ols.producto = pm.codigo_producto
group by 1, 2									
;
