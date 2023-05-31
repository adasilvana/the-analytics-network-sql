DROP TABLE IF EXISTS dim.monthly_average_fx_rate;
    
CREATE TABLE dim.monthly_average_fx_rate
                 (
					 		  id_monthly_average_fx_rate serial PRIMARY KEY
                            , mes                 DATE
                            , cotizacion_usd_peso DECIMAL
                            , cotizacion_usd_eur DECIMAL
                            , cotizacion_usd_uru  DECIMAL
                 );
