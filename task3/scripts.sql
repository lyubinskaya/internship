/*1. Вывести количество фильмов в каждой категории, отсортировать по убыванию:*/

SELECT cat.name, COUNT(fc.film_id) as count
FROM film_category fc
INNER JOIN category cat
ON fc.category_id = cat.category_id
GROUP BY cat.category_id
ORDER BY 2 DESC;


/*2. Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию:*/

SELECT a.first_name, a.last_name, count(r.rental_id) AS rental_count
FROM rental r
INNER JOIN inventory inv
ON r.inventory_id = inv.inventory_id
INNER JOIN film f
ON inv.film_id = f.film_id
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
INNER JOIN actor a
ON fa.actor_id = a.actor_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10;


/*3. Вывести категорию фильмов, на которую потратили больше всего денег:*/

SELECT catname FROM 
(SELECT cat.name AS catname, SUM(p.amount) AS total
FROM payment p
INNER JOIN rental r
ON p.rental_id = r.rental_id
INNER JOIN inventory inv
ON r.inventory_id = inv.inventory_id 
INNER JOIN film f
ON inv.film_id = f.film_id
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category cat
ON fc.category_id = cat.category_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1) AS max_total_cat;


/*4. Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN:*/

SELECT title
FROM film f
LEFT JOIN inventory inv
ON f.film_id = inv.film_id
WHERE inventory_id IS NULL;


/*5. Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. 
Если у нескольких актеров одинаковое кол-во фильмов, вывести всех:*/

SELECT a.first_name, a.last_name, count(fa.film_id)
FROM actor a
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id
INNER JOIN film f ON f.film_id = fa.film_id
INNER JOIN film_category fc ON f.film_id = fc.film_id
WHERE fc.category_id = (SELECT category_id FROM category WHERE name ='Children')
GROUP BY a.actor_id
ORDER BY 3 DESC
LIMIT 5;


/*6. Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1).
Отсортировать по количеству неактивных клиентов по убыванию:*/

SELECT city, 
count(CASE cus.active when 1 then 1 else null end) AS active_clients,
count(CASE cus.active when 0 then 1 else null end) AS inactive_clients
FROM address a
INNER JOIN customer cus
ON cus.address_id = a.address_id
INNER JOIN city
ON city.city_id = a.city_id
GROUP BY 1
ORDER BY 3 DESC;


/*7. Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city),
и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе:*/
--категории с наибольшим суммарным временем аренды в городах, фильмы начинаются на "а"
(SELECT cat.name AS category, city.city, SUM(r.return_date - r.rental_date) AS rental_period
FROM city
INNER JOIN address a 
ON city.city_id = a.city_id
INNER JOIN customer cus
ON a.address_id = cus.address_id
INNER JOIN rental r
ON cus.customer_id = r.customer_id
INNER JOIN inventory inv
ON r.inventory_id = inv.inventory_id
INNER JOIN film f
ON inv.film_id = f.film_id
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category cat
ON fc.film_id = cat.category_id
WHERE f.title LIKE 'A%' OR f.title LIKE 'a%' AND r.return_date IS NOT NULL
GROUP BY 1, 2 
ORDER BY 2)
UNION
--категории с наибольшим суммарным временем аренды в городах, города содержат "-"
(SELECT cat.name AS category, city.city, SUM(r.return_date - r.rental_date) AS rental_period
FROM city
INNER JOIN address a 
ON city.city_id = a.city_id
INNER JOIN customer cus
ON a.address_id = cus.address_id
INNER JOIN rental r
ON cus.customer_id = r.customer_id
INNER JOIN inventory inv
ON r.inventory_id = inv.inventory_id
INNER JOIN film f
ON inv.film_id = f.film_id
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category cat
ON fc.film_id = cat.category_id
WHERE city.city LIKE '%-%' AND r.return_date IS NOT NULL
GROUP BY 1, 2
ORDER BY 2);
