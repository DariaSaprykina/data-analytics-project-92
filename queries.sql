SELECT COUNT(customer_id) AS customers_count
FROM customers;



select
	concat(e.first_name,' ', e.last_name) as name,
	SUM(s.quantity) as operations,
	SUM(p.price * s.quantity) as income
from sales s
left join employees e
	on s.sales_person_id = e.employee_id
left join products p
	on p.product_id = s.product_id
group by concat(e.first_name,' ', e.last_name)
order by income desc
limit 10;


select
	concat(e.first_name,' ', e.last_name) as name,
	ROUND(AVG(p.price * s.quantity)) as average_income
from sales s
left join employees e
	on s.sales_person_id = e.employee_id
left join products p
	on p.product_id = s.product_id
group by concat(e.first_name,' ', e.last_name)
having AVG(p.price * s.quantity) <  ( 
						select AVG(p.price * s.quantity)
						from sales s
						left join products p
							on p.product_id = s.product_id
							)
order by average_income;



with TAB1 AS(
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
order by weekday_number, name
;

