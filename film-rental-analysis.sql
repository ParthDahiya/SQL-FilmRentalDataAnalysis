/***********************************************************************************/
/* 	Contact Me At:
					Github: https://github.com/ParthDahiya
                    LinkedIn: https://www.linkedin.com/in/parth-dahiya/
*/
/***********************************************************************************/

-- Analysing data from customer table 
SELECT * FROM customer LIMIT 500;

/* Email Campaigns for customers of Store 2
First, Last name and Email address of customers from Store 2*/
SELECT first_name, last_name,email
FROM customer
WHERE store_id = 2;


-- Analysing data from film table 
SELECT * FROM film LIMIT 500;

/* no. of movies with rental rate of 0.99$*/
SELECT COUNT(*) FROM film
WHERE rental_rate = 0.99;

/*rental rate and no. of movies are in each rental rate categories*/
SELECT rental_rate, COUNT(*) AS total_number_of_movies
FROM film
GROUP BY rental_rate;

SELECT rental_rate, COUNT(*) AS total_number_of_movies
FROM film
GROUP BY 1;

/*Total no. of movies for each rating*/
SELECT rating,COUNT(*) AS total_number_of_movies
FROM film
GROUP BY 1;

/*Which rating is most prevalant in each store?*/
SELECT s.store_id, f.rating, COUNT(f.rating) AS total_number_of_films
FROM store s
JOIN inventory i ON s.store_id = i.store_id
JOIN film f ON f.film_id = i.film_id
GROUP BY 1,2;


/*To find all the information used to reach customer*/
SELECT c.customer_id, c.first_name, c.last_name, c.email, a.address
FROM customer c
JOIN address a ON c.address_id = a.address_id;


/* List of films by Film Name, Category, Language*/
SELECT f.title,c.name category,l.name language
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN language l ON l.language_id = f.language_id;


/* How many times each movie has been rented out and most rented movie*/
SELECT i.film_id, f.title, COUNT(i.film_id) AS total_number_of_rental_times
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id
GROUP BY i.film_id
ORDER BY 3 DESC;


/*Total Revenue per Movie */
SELECT i.film_id, f.title, COUNT(i.film_id) AS total_number_of_rental_times, f.rental_rate, COUNT(i.film_id)*f.rental_rate AS revenue_per_movie
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id
GROUP BY i.film_id
ORDER BY 5 DESC;


/* Most Spending Customer */
SELECT c.customer_id, CONCAT(first_name, ' ', last_name) AS Name, SUM(p.amount) AS "Total Spending"
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY 1
ORDER BY 3 DESC;


/* What Store has brought the most revenue */
SELECT s.store_id, SUM(p.amount) AS "Total revenue"
FROM store s
JOIN inventory i ON i.store_id = s.store_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY 1
ORDER BY 2 DESC;


/*How many rentals we have for each month*/
SELECT left(rental_date,7) AS "Month", COUNT(*)
FROM rental
GROUP BY 1;

/* Rentals per Month (such Jan => How much, etc)*/
SELECT date_format(rental_date,"%M") AS "Month", COUNT(*)
FROM rental
GROUP BY 1
ORDER BY 2 DESC;

/* Which date first movie was rented out ? */
SELECT MIN(rental_date)
FROM rental;

/* Which date last movie was rented out ? */
SELECT MAX(rental_date)
FROM rental;

/* For each movie, when was the first time and last time it was rented out? */
SELECT f.title AS "Film Title", MIN(r.rental_date) AS "First Rented Date", MAX(r.rental_date) AS "Last Rented Date"
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY 1;

/* Last Rental Date of every customer */
SELECT c.customer_id, c.first_name, c.last_name, MAX(r.rental_date) AS "Last Rental Date"
FROM customer c
JOIN rental r ON r.customer_id = c.customer_id
GROUP BY 1;

/* Revenue Per Month */
SELECT LEFT(payment_date,7) AS "Month", SUM(amount) AS "Revenue Per Month"
FROM payment
GROUP BY 1;

/* How many distint Renters per month*/
SELECT LEFT(rental_date,7) AS "Month", 
	COUNT(DISTINCT(rental_id)) AS "Total Rentals",
	COUNT(DISTINCT(customer_id)) AS "Number Of Unique Renter", 
    COUNT(DISTINCT(rental_id))/COUNT(DISTINCT(customer_id)) AS "Average Rent Per Renter"
FROM rental
GROUP BY 1;

/*Most Rented Film Each Month */
SELECT i.film_id, f.title, LEFT(r.rental_date,7) AS "Month", COUNT(i.film_id) AS "Total Number Of Rental Times"
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON f.film_id = i.film_id
GROUP BY i.film_id, f.title
ORDER BY 4 desc;

/* Number of Rentals as per Genre (Comedy , Sports, Family) */
SELECT c.name AS 'Category', COUNT(c.name) AS "Number of Rentals"
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = fc.category_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
WHERE c.name IN ("Comedy", "Sports", "Family")
GROUP BY 1;

/*Total no. of rentals by each customer and most active customer*/
SELECT c.customer_id, CONCAT(c.first_name, " ", c.last_name) AS "Customer Name", COUNT(c.customer_id) AS "Total Rentals"
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY 1
HAVING COUNT(c.customer_id) >= 3
ORDER BY 1;

/*Total revenue on the bases of rating and stores*/
SELECT s.store_id, f.rating, SUM(p.amount) AS "Total Revenue"
FROM store s 
JOIN inventory i ON i.store_id = s.store_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
JOIN film f ON f.film_id = i.film_id
GROUP BY 1,2;

/*******************************************************/

/* Active User  where active = 1*/
DROP TEMPORARY TABLE IF EXISTS tbl_active_users;
CREATE TEMPORARY TABLE tbl_active_users(
SELECT c.*, a.phone
FROM customer c
JOIN address a ON a.address_id = c.address_id
WHERE c.active = 1);


/* Reward Users : who has rented at least 30 times*/
DROP TEMPORARY TABLE IF EXISTS tbl_rewards_user;
CREATE TEMPORARY TABLE tbl_rewards_user(
SELECT r.customer_id, COUNT(r.customer_id) AS total_rents, max(r.rental_date) AS last_rental_date
FROM rental r
GROUP BY 1
HAVING COUNT(r.customer_id) >= 30);

/* Reward Users who are also active */
SELECT au.customer_id, au.first_name, au.last_name, au.email
FROM tbl_rewards_user ru
JOIN tbl_active_users au ON au.customer_id = ru.customer_id;

/* All Rewards Users with Phone */
SELECT ru.customer_id, c.email, au.phone
FROM tbl_rewards_user ru
LEFT JOIN tbl_active_users au ON au.customer_id = ru.customer_id
JOIN customer c ON c.customer_id = ru.customer_id;
