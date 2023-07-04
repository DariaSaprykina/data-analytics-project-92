/* Общее кол-во покупателей. 
 * Файл customers_count */
SELECT COUNT(customer_id) AS customers_count
FROM customers;


/* ТОП-10 лучших продавцов - самая большая выручка за данный период. 
 * Файл op_10_total_income.csv  */
select
	concat(e.first_name,' ', e.last_name) as name, --соединяем имя и фамилию
	SUM(s.quantity) as operations, --кол-во проданных товаров
	SUM(p.price * s.quantity) as income --доход от проданных товаров
from sales s
left join employees e
	on s.sales_person_id = e.employee_id
left join products p
	on p.product_id = s.product_id
group by concat(e.first_name,' ', e.last_name) --группируем по фио продавца 
order by income desc
limit 10; -- выводим 10 записей, предварительно сортируя по выручке


/* Продавцы, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. 
 * Файл lowest_average_income.csv */
select
	concat(e.first_name,' ', e.last_name) as name,
	ROUND(AVG(p.price * s.quantity)) as average_income --средняя выручка за продажу по продавцу с группировкой по продавцу
from sales s
left join employees e
	on s.sales_person_id = e.employee_id
left join products p
	on p.product_id = s.product_id
group by concat(e.first_name,' ', e.last_name) 
having AVG(p.price * s.quantity) <  ( --после того, как имеем сгруппированные по продавцу данные, применяем условие отбора
						select AVG(p.price * s.quantity) -- средняя продажа по всей выборке 
						from sales s
						left join products p
							on p.product_id = s.product_id
							)
order by average_income;


/* Выручка всех продавцов по дням недели
 * Файл day_of_the_week_income.csv */
with TAB1 as (
select
	concat(e.first_name,' ', e.last_name) as name,
	TO_CHAR((sale_date),'fmday') as weekday,
	ROUND(SUM(p.price * s.quantity)) as income,
	extract(isodow from sale_date) as weekday_number
from sales s
left join employees e
	on s.sales_person_id = e.employee_id
left join products p
	on p.product_id = s.product_id
group by concat(e.first_name,' ', e.last_name), sale_date, TO_CHAR((sale_date),'fmDay')
)

select name, weekday, SUM(income) as income
from tab1
group by name, weekday, weekday_number
order by weekday_number, name;



/* Количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+.
 * Файл age_groups.csv 
 */

with tab2 as(
	select customer_id,
	age,
	case
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		else '40+'
	end as age_category
	from customers
)

select distinct age_category,
COUNT(customer_id)
from tab2
group by age_category
order by 1;


/*Количеству уникальных покупателей и выручке, которую они принесли по месяцам 
* customers_by_month.csv
*/

with tab3 as (
	select 
		to_char(sale_date,'YYYY-MM') as date, -- дата в формате год-месяц
		s.customer_id as customer_unic, 
		SUM(s.quantity * p.price) as income -- выручка по каждому покупателю
	from sales s
	join products p
		on p.product_id = s.product_id
	group by date, s.customer_id
)

select
	date,
	count(customer_unic) as total_customers,
	SUM(income) as income
from tab3
group by date
order by 1;


/* Покупатели - первая покупка была сделана в ходе проведения акций (стоимостью товаров = 0). 
* Файл special_offer.csv 
*/

with tab4 as (select 
	sale_date,
	concat(c.first_name,' ', c.last_name) as customer,
	concat(e.first_name,' ', e.last_name) as seller,
	first_value(sale_date) over(partition by s.customer_id order by s.customer_id, sale_date) as first_value_date,
	p.price
from sales s
left join products p
	on p.product_id = s.product_id
left join employees e 
	on e.employee_id  = s.sales_person_id
left join customers c 
	on c.customer_id = s.customer_id
)
select
	distinct on(customer) customer, 
	sale_date, 
	seller
from tab4
where price = 0
;





