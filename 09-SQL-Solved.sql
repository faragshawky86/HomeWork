-- Homework Assignment 06-SQL
use sakila;
-- 1a. Display the first and last names of all actors from the table `actor`.
select actor.first_name, actor.last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select actor.first_name, actor.last_name ,concat(UPPER(actor.first_name) ,' ',UPPER( actor.last_name)) as ActorName from actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name from actor 
WHERE 
first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`
select * from actor
where 
last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order
select * from actor 
WHERE 
last_name like "%LI%"
order by last_name, first_name;

-- Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China
select country_id, country 
from country
where country IN ("Afghanistan", "Bangladesh", "China");


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description blob AFTER last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name
select last_name, count(last_name)  
from actor
group by(last_name);

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name)  
from actor
group by(last_name)
having count(last_name) > 1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update  actor
set first_name = "HARPO"
where first_name = "GROUCHO" and last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor
set first_name = "GROUCHO"
where first_name = "HARPO";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

CREATE TABLE  if not exists `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
select first_name, last_name, address.address
from 
staff join address on staff.address_id = address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select staff.staff_id,first_name, last_name, sum(amount)
from staff join payment on staff.staff_id = payment.staff_id
group by staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select film.film_id, film.title, film.release_year, count(actor_id) as Number_of_Actors
from film join film_actor on film_actor.film_id = film.film_id
group by (film.film_id);

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select film.title, count(inventory.inventory_id) as Number_of_Copies
from inventory join film on inventory.film_id = film.film_id
where film.title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name
select payment.customer_id,concat(first_name,' ', customer.last_name) as customer_name, sum(amount)
from 
payment join customer on payment.customer_id = customer.customer_id
group by customer_id;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select * from film
where
title in (select title from film where (title like "K%" or title like "Q%") and (language_id = 1));

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select * from film join film_actor
on film.film_id = film_actor.film_id
where film.title in (select title from film where
film.title = "Alone Trip");

-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select * from customer join address 
on customer.address_id = address.address_id
where
city_id in (select city_id from city join country on city.country_id = country.country_id where country.country_id in (select country_id from country where country = "Canada")) ;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
select * from film join film_category
 on film.film_id = film_category.film_id
 where category_id in (select category_id from category where category.name = "Family");
 
 -- 7e. Display the most frequently rented movies in descending order.
SELECT * , count(*) as times_rented FROM sakila.rental join film
on film.film_id = rental.inventory_id
group by inventory_id
order by times_rented desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store_id, sum(amount) as total_sales from payment join staff
on payment.staff_id = staff.staff_id
where store_id in 
(select store.store_id from staff join store 
on store.store_id = staff.store_id )
group by store_id;

--  7g. Write a query to display for each store its store ID, city, and country.
select store_id, country, city 
from country 
join city on country.country_id = city.country_id
join address on address.city_id = city.city_id
join store on store.address_id = address.address_id

-- 7h. List the top five genres in gross revenue in descending order.
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select  category.category_id, name, sum(amount) as category_revenue from rental 
join payment on payment.rental_id = rental.rental_id
join inventory on inventory.inventory_id = rental.inventory_id
join film_category on film_category.film_id = inventory.film_id
join category on category.category_id = film_category.category_id
group by category_id
order by category_revenue desc
limit 5;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `sakila`.`top_5_geners` AS
    SELECT 
        `sakila`.`category`.`category_id` AS `category_id`,
        `sakila`.`category`.`name` AS `name`,
        SUM(`sakila`.`payment`.`amount`) AS `category_revenue`
    FROM
        ((((`sakila`.`rental`
        JOIN `sakila`.`payment` ON ((`sakila`.`payment`.`rental_id` = `sakila`.`rental`.`rental_id`)))
        JOIN `sakila`.`inventory` ON ((`sakila`.`inventory`.`inventory_id` = `sakila`.`rental`.`inventory_id`)))
        JOIN `sakila`.`film_category` ON ((`sakila`.`film_category`.`film_id` = `sakila`.`inventory`.`film_id`)))
        JOIN `sakila`.`category` ON ((`sakila`.`category`.`category_id` = `sakila`.`film_category`.`category_id`)))
    GROUP BY `sakila`.`category`.`category_id`
    ORDER BY `category_revenue` DESC
    LIMIT 5
    
    -- 8b. How would you display the view that you created in 8a?
    select * from top_5_geners;
    
    -- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
    DROP VIEW IF EXISTS
    top_5_geners