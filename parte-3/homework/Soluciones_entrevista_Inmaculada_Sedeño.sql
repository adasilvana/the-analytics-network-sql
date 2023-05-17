-- Ejercicios de entrevistas parte 3

-- Ejercicio 1

-- Ejecutar el siguiente script para crear las siguientes tablas dentro del esquema test.
create table test.emp_2022
( 	emp_id int,
	designation varchar(20));

create table test.emp_2023
( 	emp_id int,
	designation varchar(20));

insert into test.emp_2022 values (1,'Trainee'), (2,'Developer'),(3,'Senior Developer'),(4,'Manager');
insert into test.emp_2023 values (1,'Developer'), (2,'Developer'),(3,'Manager'),(5,'Trainee');

-- Armar una tabla con el id del empleado y una columna que represente si el empleado "Ascendio" , "Renuncio", o se "Incorporo". 
-- En caso de no haber cambios, no mostrarlo. Un empleado renuncia cuando esta el primer año y no el segundo, y viceversa para cuando un empleado se incorpora.
with jerarquia as(
select 
	coalesce(e22.emp_id, e23.emp_id) as emp_id,
	case when e22.designation = 'Trainee' then 1
	when e22.designation = 'Developer' then 2
	when e22.designation = 'Senior Developer' then 3
	when e22.designation = 'Manager' then 4 end as jerarquia22,
	case when e23.designation = 'Trainee' then 1
	when e23.designation = 'Developer' then 2
	when e23.designation = 'Senior Developer' then 3
	when e23.designation = 'Manager' then 4 end as jerarquia23
from test.emp_2022 e22
full outer join test.emp_2023 e23
on e22.emp_id = e23.emp_id)
select emp_id,
    case when jerarquia23 > jerarquia22 then 'Ascendio'
	when jerarquia23 is null then 'Renuncio'
	when jerarquia22 is null then 'Incorporo' end as Cambios
from jerarquia
where case when jerarquia23 > jerarquia22 then 'Ascendio'
	when jerarquia23 is null then 'Renuncio'
	when jerarquia22 is null then 'Incorporo' end is not null
;

-- Ejercicio 2

-- Ejecutar el siguiente script para crear la tabla orders dentro del esquema test.
create table test.orders (
	order_id integer,
	customer_id integer,
	order_date date,
	order_amount integer
	);

insert into test.orders values
 (1,100,cast('2022-01-01' as date),2000)
,(2,200,cast('2022-01-01' as date),2500)
,(3,300,cast('2022-01-01' as date),2100)
,(4,100,cast('2022-01-02' as date),2000)
,(5,400,cast('2022-01-02' as date),2200)
,(6,500,cast('2022-01-02' as date),2700)
,(7,100,cast('2022-01-03' as date),3000)
,(8,400,cast('2022-01-03' as date),1000)
,(9,600,cast('2022-01-03' as date),3000)
;

-- Encontrar para cada dia, cuantas ordenes fueron hechas por clientes nuevos ("first_purchase") y cuantas fueron hechas por clientes que ya habian comprado ("repeat_customer"). 
-- Este es un concepto que se utiliza mucho en cualquier empresa para entender la capacidad de generar clientes nuevos o de retener los existentes.
with primera_fecha as(
	select
		*,
		first_value(order_date) over (partition by customer_id order by order_date) as primera_fecha_cliente
	from test.orders
), clientes_nuevos_repetidos as(
	select
		order_id,
		customer_id,
		order_date,
		order_amount,
		case when primera_fecha_cliente = order_date then 'first_purchase'
		else 'repeat_customer' end as tipo_cliente
	from primera_fecha
)
select 
    order_date,
	tipo_cliente,
	count(order_id)
from clientes_nuevos_repetidos
group by 1,2
order by 1
;
