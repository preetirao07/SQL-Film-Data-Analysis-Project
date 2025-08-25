-- PROJECT: Film data Analysis

-- Level: Simple
-- Topic: DISTINCT
-- Task: Create a list of all different (DISTINCT) replacement costs of the films
-- Question: What's the lowest replacement cost?

select distinct(replacement_cost) from film
order by 1 asc

select min(replacement_cost) from film

-- Level: Moderate
-- Topic: CASE + GROUP BY
-- Task: Write a query that gives an overview of how many films have replacements costs in the following cost ranges
-- 	1. low: 9.99 - 19.99
-- 	2. medium: 20.00 - 24.99
-- 	3. high: 25.00 - 29.99
-- Question: How many films have a replacement cost in the "low" group?

select count(*),
case 
when replacement_cost between 9.99 and 19.99 then 'low'
when replacement_cost between 20.00 and 24.99 then 'medium'
when replacement_cost between 25.00 and 29.99 then 'high'
end as level
from film
group by level


-- Level: Moderate
-- Topic: JOIN
-- Task: Create a list of the film titles including their title, length and category name ordered descendingly by length. 
-- Filter the results to only the movies in the category 'Drama' and 'Sports'.
-- Question: In which category is the longest film & how long is it?

select title, length, c.name from film f
inner join film_category fc
on f.film_id = fc.film_id
inner join category c
on fc.category_id = c.category_id 
where name = 'Drama' or name = 'Sports'
order by length desc

-- Level: Moderate
-- Topic: JOIN & GROUP BY
-- Task: Create an overview of how many movies(titles) there are in each category(name).
-- Question: Which category (name) is the most common among the films?

select count(*), c.name from film f
inner join film_category fc
on f.film_id = fc.film_id
inner join category c
on fc.category_id = c.category_id 
group by name
order by count desc

-- Level: Moderate
-- Topic: JOIN & GROUP BY
-- Task: Create an overview of the actors' first and last names how many movies(titles) they appear in.
-- Question: Which actor is part of most movies?
select count(*), a.actor_id, a.first_name, a.last_name from film f
inner join film_actor fa on f.film_id = fa.film_id
inner join actor a on fa.actor_id = a.actor_id
group by a.actor_id, a.first_name, a.last_name
order by count(*) desc


-- Level: Moderate
-- Topic: LEFT JOIN & FILTERING
-- Task: Create an overview of the addresses that are not associated to any customer
-- Question: How many addresses are that?
select count(*) from address a
left join customer c 
on c.address_id = a.address_id
where c.first_name is NULL 


-- Level: Moderate
-- Topic: JOIN & GROUP BY
-- Task: Create an overview of the sales to determine the from which city (we are interested in the city in which the customer lives,
-- not where the store is) most sales occur.
-- Question: What city is that and how much is the amount?
select city, sum(amount) from payment p
left join customer c on p.customer_id = c.customer_id
left join address a on a.address_id = c.address_id
left join city ci on ci.city_id = a.city_id
group by city
order by sum desc

-- Level: Moderate to difficult
-- Topic: CUSTOM COLUMN, JOIN & GROUP BY
-- Task: Create an overview of the revenue(sum of amount) grouped by a column in the format "country,city".
-- Question: Which country,city has the least sales?
select country ||', ' ||city, sum(amount) from payment p
left join customer c on p.customer_id = c.customer_id
left join address a on a.address_id = c.address_id
left join city ci on ci.city_id = a.city_id
left join country co on ci.country_id = co.country_id 
group by country ||', ' ||city
order by 2 asc


-- Level: Difficult
-- Topic: Uncorealted sub-query
-- Task: Create a list with the average of the sales amount each staff_id has per customer.
-- Question: Which staff_id makes on average revenue of 56.64 per customer.
select staff_id, round(avg(total), 2) from (select staff_id, sum(amount)as total, customer_id  from payment group by customer_id, staff_id)
group by staff_id



-- Level: Difficult to very difficult
-- Topic: EXTRACT and Uncorealted sub-query
-- Task: Create a query that shows average daily revenue of all the sundays.
-- Question: What is the daily average revenue of all sundays?

select round(avg(total), 2) 
from 
(select sum(amount) as total, DATE(payment_date), extract(dow from payment_date) as weekday 
from payment
where extract(dow from payment_date) = 0
group by DATE(payment_date), weekday)


-- Level: Difficult to very difficult
-- Topic: Corealted sub-query
-- Task: Create a list of movies - with their length and their replacement_cost - that are longer than the average length in each replacement cost group.
-- Question: Which two movies are the shortest on that list and how long are they?
select title, length, replacement_cost from film f1
where length > (select avg(length) from film f2 
					where f1.replacement_cost = f2.replacement_cost) 
order by length asc


-- Level: Difficult to very difficult
-- Topic: Uncorealted sub-query
-- Task: Create a list that shows the "average customer lifetime value" grouped by districts
-- Question: Which district has the highest average customer lifetime value?
select district, round(avg(total), 2) as avg_customer_lifetime_value from 
	(select c.customer_id, district, sum(amount) as total from payment p
		inner join customer c on p.customer_id = c.customer_id
		inner join address a on c.address_id = a.address_id
		group by a.district, c.customer_id)
sub group by district
order by 2 desc


-- Level: Difficult to very difficult
-- Topic: Corealted query
-- Task: Create a list that shows all payments including payment_id, amount, and the film category(name)
-- plus the total amount that was made in this category. Order the results ascendingly by the category(name) and as sexond order criterion by the payment_id asc.
-- Question: What is the total revenue of the category 'Action' and what is the lowest payment_id in that category 'Action'?

select f.title, p.payment_id, p.amount, name,  
											(select sum(amount) from payment p
											left join rental r on r.rental_id = p.rental_id
											left join inventory i on r.inventory_id = i.inventory_id
											inner join film f on i.film_id = f.film_id
											inner join film_category fc on f.film_id = fc.film_id
											inner join category c1 on fc.category_id = c1.category_id 
											where c1.name = c.name) 
from payment p
											left join rental r on r.rental_id = p.rental_id
											left join inventory i on r.inventory_id = i.inventory_id
											inner join film f on i.film_id = f.film_id
											inner join film_category fc on f.film_id = fc.film_id
											inner join category c on fc.category_id = c.category_id 
order by name


-- Level: Extremely difficult
-- Topic: Corealted query and Uncorealted query
-- Task: Create a list with the top overall revenue of a film title (sum of amount per title) for each category(name)
-- Question: Which is the top-performing film in the animation category?
select
title,
name,
sum(amount) as total from payment p
left join rental r on r.rental_id = p.rental_id
left join inventory i on i.inventory_id = r.rental_id
left join film f on f.film_id = i.film_id
left join film_category fc on fc.film_id = f.film_id
left join category c on c.category_id = fc.category_id
group by name, title
having sum(amount) = (select max(total) from (select title, name,
sum(amount) as total
from payment p
left join rental r on r.rental_id = p.rental_id
left join inventory i on i.inventory_id = r.rental_id
left join film f on f.film_id = i.film_id
left join film_category fc on fc.film_id = f.film_id
left join category c1 on c1.category_id = fc.category_id
group by name, title) 
sub where c.name=sub.name)
