DROP TABLE IF EXISTS fct.super_store_count;
    
CREATE TABLE fct.super_store_count
                 (
			      id_store_count SERIAL PRIMARY KEY
                            , tienda SMALLINT
                            , fecha  VARCHAR(10)
                            , conteo SMALLINT
					 
			    , constraint fk_tienda_id_super_store_count
                            foreign key (tienda)
                            references dim.store_master (codigo_tienda)
                 );
