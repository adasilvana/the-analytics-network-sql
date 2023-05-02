-- Ejercicios entrevistas

-- Ejercicio 1

-- Ejecutar el siguiente script para crear la tabla turistas dentro del esquema test.
create schema test;
drop table if exists test.turistas;
create table test.turistas(city varchar(50),days date,personas int);
insert into test.turistas values('CABA','2022-01-01',100);
insert into test.turistas values('CABA','2022-01-02',200);
insert into test.turistas values('CABA','2022-01-03',300);
insert into test.turistas values('Cordoba','2022-01-01',100);
insert into test.turistas values('Cordoba','2022-01-02',100);
insert into test.turistas values('Cordoba','2022-01-03',300);
insert into test.turistas values('Madrid','2022-01-01',100);
insert into test.turistas values('Madrid','2022-01-02',200);
insert into test.turistas values('Madrid','2022-01-03',150);
insert into test.turistas values('Punta del Este','2022-01-01',100);
insert into test.turistas values('Punta del Este','2022-01-02',300);
insert into test.turistas values('Punta del Este','2022-01-03',200);
insert into test.turistas values('Punta del Este','2022-01-04',400);
;

-- ¿Cuales son las ciudades donde la afluencia de turistas es continuamente creciente?
with diferencia as(
select city, 
  days,
  lag(personas) over(partition by city order by days) as personas_dia_anterior,
  personas - lag(personas) over(partition by city order by days) as diferencia_personas
from test.turistas)
, diferencia_negativa as(
  select 
	     city,
	     days,
	     (case when diferencia_personas > 0 or diferencia_personas is null then 0 else 1 end) as count_diferencia_negativa_personas
  from diferencia)
select 
	city,
	sum(count_diferencia_negativa_personas) as numero_disminuciones
from diferencia_negativa
group by 1
having sum(count_diferencia_negativa_personas) = 0
;


-- Ejercicio 2

-- Ejecutar el siguiente script para crear la tabla empleados dentro del esquema test.
drop table if exists test.empleados;
create table test.empleados (emp_id int, empleado varchar(50), salario bigint, manager_id int);
insert into test.empleados values (1,'Clara',10000,4);
insert into test.empleados values (2,'Pedro',15000,5);
insert into test.empleados values (3,'Daniel',10000,4);
insert into test.empleados values (4,'Hernan',5000,2);
insert into test.empleados values (5,'Debora',12000,6);
insert into test.empleados values (6,'Ricardo',12000,2);
insert into test.empleados values (7,'Luciano',9000,2);
insert into test.empleados values (8,'Romina',5000,2);

-- Encontrar a los empleados cuyo salario es mayor que el de su manager
with diferencia as(
select e.emp_id,
     e1.empleado as nombre_empleado,
	 e1.salario as salario_empleado,
	 e.manager_id,
	 e.empleado as nombre_manager,
	 e.salario as salario_manager,
	 e1.salario - e.salario as diferencia_empleado_manager
from test.empleados e 
left join test.empleados e1
on e.emp_id = e1.manager_id)
select nombre_empleado,
	nombre_manager,
	diferencia_empleado_manager
from diferencia
where diferencia_empleado_manager >0 
;


-- Ejercicio 3

-- Ejecutar el siguiente script para crear la tabla players y matches dentro del esquema test.
drop table if exists test.players;
create table test.players (player_id int, team_group varchar(1));
insert into test.players values (15,'A');
insert into test.players values (25,'A');
insert into test.players values (30,'A');
insert into test.players values (45,'A');
insert into test.players values (10,'B');
insert into test.players values (35,'B');
insert into test.players values (50,'B');
insert into test.players values (20,'C');
insert into test.players values (40,'C');
create table test.matches (match_id int, first_player int, second_player int, first_score int, second_score int);
insert into test.matches values (1,15,45,3,0);
insert into test.matches values (2,30,25,1,2);
insert into test.matches values (3,30,15,2,0);
insert into test.matches values (4,40,20,5,2);
insert into test.matches values (5,35,50,1,1);

-- Encontrar el player_id ganador de cada grupo. El ganador es aquel que anota mas puntos (score) en caso de empate, el que tenga menor player_id gana.
with puntos_totales as(
with total_puntos as(
select match_id, first_player as player, first_score as score
from test.matches
union all
select match_id, second_player as player, second_score as score
from test.matches
)
select tp.player, pla.team_group, sum(tp.score) as total_score
from total_puntos tp
left join test.players pla
on pla.player_id = tp.player
group by 1,2
order by 2, 3 desc, 1 asc
)
select distinct first_value(player) over (partition by team_group order by total_score desc, player asc) as id_ganador, team_group
from puntos_totales
;
