use a_shop;

-- -----------------------------------------------------------------------------------------------------
--  ===== количество заказанных товара у каждого пользователя ===== 
-- -----------------------------------------------------------------------------------------------------

SELECT profiles.user_id, SUM(quantity) AS quantity_orders
	FROM
		profiles
	LEFT JOIN 
		orders_products
	ON profiles.user_id = orders_products.orders_id
GROUP BY profiles.user_id
ORDER BY quantity_orders DESC;

-- или можно вывести пользователя таким оброзом, отличия больше данных о покупателе 
/*SELECT orders.customer_id, sum(quantity) as quantity_orders
	FROM
		orders
	JOIN 
		orders_products
	ON orders.customer_id = orders_products.orders_id
group by orders.customer_id
ORDER BY quantity_orders DESC;*/

-- -----------------------------------------------------------------------------------------------------
--  ===== Просмотр все категории заказа конкретного пользователя ===== 
-- -----------------------------------------------------------------------------------------------------

SELECT CONCAT(users.firstname,' ', users.lastname) AS customer, orders_products.goods_id
	FROM 
		users
	JOIN
		orders_products
	ON users.id=orders_products.orders_id
WHERE users.id=2;

-- -----------------------------------------------------------------------------------------------------
--  ===== Определить кто больше совершает заказов (всего): мужчины или женщины ===== 
-- -----------------------------------------------------------------------------------------------------		

SELECT 
	CASE (gender)
         WHEN 'm' THEN 'мужчин'
         WHEN 'f' THEN 'женщин'
    END AS 'больше всех', COUNT(*) AS 'orders_total'
FROM 
	profiles p 
JOIN
	orders_products op 
ON 
	op.orders_id = p.user_id 
GROUP BY gender;

-- -----------------------------------------------------------------------------------------------------
--  ===== выясним список всех товаров в разделе для женшин =====  
-- -----------------------------------------------------------------------------------------------------

SELECT 
	id, 
	name, 
	goods_catid, 
	price 
FROM 
	products p 
WHERE
	goods_catid = (SELECT id FROM catalogs WHERE cat_name='For Women' )
ORDER BY price DESC; 

-- -----------------------------------------------------------------------------------------------------
-- ===== Получим кто больше оставил отзывов о товаре (мужчины или женщины) ===== 
-- -----------------------------------------------------------------------------------------------------

SELECT
	CASE (gender)
         WHEN 'm' THEN 'мужчин'
         WHEN 'f' THEN 'женщин'
    END  AS 'больше всех',
	COUNT(*) AS count_comments
FROM profiles p
JOIN users AS u ON u.id = p.user_id
JOIN comments AS c ON c.user_id = u.id
GROUP BY p.gender;

-- -----------------------------------------------------------------------------------------------------
-- ===== Выборка кто сколько написал сообщений менеджеру =====
-- -----------------------------------------------------------------------------------------------------
SELECT
	users.id, CONCAT(users.firstname,' ', users.lastname) AS name,
	count(*) AS total_messages
FROM users
JOIN messages
	ON users.id = messages.from_user_id
GROUP BY users.id
ORDER BY total_messages DESC;

-- -----------------------------------------------------------------------------------------------------
--  ===== Все товары чья цена ниже среднего ===== 
-- -----------------------------------------------------------------------------------------------------

SELECT 
	id, 
	name, 
	goods_catid, 
	price 
FROM 
	products
WHERE price < (SELECT AVG(price) FROM products);

-- -----------------------------------------------------------------------------------------------------
--  ===== сколько в каждом месяце было сделано заказов ===== 
-- -----------------------------------------------------------------------------------------------------

SELECT
	MONTHNAME (dates) AS date_name,
	COUNT(id) AS cnt  
FROM
	orders
GROUP BY date_name
ORDER BY cnt DESC;

-- -----------------------------------------------------------------------------------------------------











