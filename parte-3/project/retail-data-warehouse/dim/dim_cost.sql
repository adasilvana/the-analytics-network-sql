
DROP TABLE IF EXISTS dim.cost;
    
CREATE TABLE dim.cost
                 (
                              codigo_producto    VARCHAR(10) PRIMARY KEY
                            , costo_promedio_usd DECIMAL
					 		
					 		              constraint fk_tienda_id_cost
                            foreign key (codigo_producto)
                            references dim.product_master (codigo_producto)
                 );
