# Lab | SQL Self and cross join

#In this lab, you will be using the [Sakila](https://dev.mysql.com/doc/sakila/en/) database of movie rentals.

### Instructions
use sakila;

select a.account_id, a.disp_id, a.client_id, a.type, b.disp_id, b.client_id, b.type from bank.disp as a
join bank.disp as b
on a.disp_id <> b.disp_id
and a.account_id = b.account_id
where a.type="OWNER"
order by a.account_id;

#1. Get all pairs of actors that worked together.

select f1.film_id, 
		f1.actor_id as actor_1, a1.first_name as actor_f1, a1.last_name as actor_l1, 
        f2.actor_id as actor_2, a2.first_name as actor_f2, a2.last_name as actor_l2
#selfjoin to get the pairs without duplicates, matching by film_id
from sakila.film_actor as f1
join sakila.film_actor as f2
on f1.actor_id > f2.actor_id
and f1.film_id=f2.film_id
#join with actor table for names of the first actor
join sakila.actor as a1
on f1.actor_id=a1.actor_id
#join with actor table for names of the second actor
join sakila.actor as a2
on f2.actor_id=a2.actor_id
order by f1.film_id;

#different approach
use sakila;
SELECT DISTINCT f1.actor_id, f2.actor_id, f1.film_id
FROM film_actor f1
JOIN film_actor f2
ON f1.film_id = f2.film_id AND f1.actor_id <> f2.actor_id;

#Get all customers that have rented the same film more than 3 times.
#get the number of total rents
select c.customer_id, c.first_name, c.last_name, count(r.rental_id)#, count(i.film_id)
from sakila.customer as c
join sakila.rental as r
on c.customer_id =r.customer_id
group by r.customer_id;

select c.customer_id, c.first_name, c.last_name, count(i.film_id) as n_rented, f.title
from sakila.customer as c
join sakila.rental as r
on c.customer_id =r.customer_id
join sakila.inventory as i
on r.inventory_id=i.inventory_id
join sakila.film as f
on i.film_id=f.film_id
group by c.customer_id, c.first_name, c.last_name, f.title
having n_rented >2
order by n_rented desc;

#2. Get all pairs of customers that have rented the same film more than 3 times.
select count(f1.title) as n_movies, 
	c1.customer_id as customer_1, c1.first_name, c1.last_name, 
	c2.customer_id as customer_2, c2.first_name, c2.last_name
from sakila.customer as c1
	join sakila.rental as r1 on c1.customer_id = r1.customer_id
	join sakila.inventory as i1 on r1.inventory_id=i1.inventory_id
	join sakila.film as f1 on i1.film_id=f1.film_id
    #going the path backwards to find customer with the same rented movies 
    join sakila.inventory as i2 on i2.film_id=f1.film_id
    join sakila.rental as r2 on i2.inventory_id =r2.inventory_id
    join sakila.customer as c2 on r2.customer_id=c2.customer_id
#using greater than to drop duplicates
where c1.customer_id>c2.customer_id
group by c1.customer_id, c1.first_name, c1.last_name, c2.customer_id, c2.first_name, c2.last_name
Having n_movies>3
order by n_movies desc;

#3. Get all possible pairs of actors and films.
select f3.title,
	f2.actor_id as actor_1, a1.first_name, a1.last_name, 
	a2.actor_id as actor_2, a2.first_name, a2.last_name
from film_actor as f1
	join film_actor as f2 on f1.actor_id>f2.actor_id
    and f1.film_id=f2.film_id
	join actor as a1 on f1.actor_id= a1.actor_id
    join actor as a2 on f2.actor_id=a2.actor_id
    join film as f3 on f1.film_id=f3.film_id
order by title, a1.last_name, a2.last_name;