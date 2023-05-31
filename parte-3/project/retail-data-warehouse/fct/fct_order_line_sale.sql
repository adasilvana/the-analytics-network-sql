DROP TABLE IF EXISTS fct.order_line_sale;
    
CREATE TABLE fct.order_line_sale
                 (
                              orden      VARCHAR(10) 
                            , producto   VARCHAR(10)
                            , tienda     SMALLINT
                            , fecha      date
                            , cantidad   int
                            , venta      decimal(18,5)
                            , descuento  decimal(18,5)
                            , impuestos  decimal(18,5)
                            , creditos   decimal(18,5)
                            , moneda     varchar(3)
                            , pos        SMALLINT
                            , is_walkout BOOLEAN
			 
			   , PRIMARY KEY (orden, producto)
					 
			    , constraint fk_tienda_id_order_line_sale
                            foreign key (tienda)
                            references dim.store_master (codigo_tienda)
                            
                            , constraint fk_sku_id_order_line_sale
                            foreign key (producto)
                            references dim.product_master (codigo_producto)
                 );
				 
