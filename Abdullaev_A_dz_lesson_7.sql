/*1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.*/

/* Так как таблица orders и orders_products пусты, добавил несколько записей */

ALTER TABLE orders ADD CONSTRAINT fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE;

INSERT INTO orders(user_id)
VALUES (1), (2), (3), (1), (2);

ALTER TABLE orders_products ADD CONSTRAINT fk_orders_id
    FOREIGN KEY (order_id) REFERENCES orders(id)
    ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE orders_products ADD CONSTRAINT fk_products_id
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON UPDATE CASCADE ON DELETE CASCADE;
   
INSERT INTO orders_products(order_id, product_id)
VALUES (1, 7), (1, 1), (3, 2), (4, 3), 
	   (5, 1);
	   
-- решение задачи
	  
SELECT users.id, users.name 
	FROM
		users
	JOIN 
		orders 
	ON users.id = orders.user_id;

-- второй вариант решения задачи не точный, более точный с join
-- SELECT id, name FROM users WHERE id in (SELECT user_id FROM orders); 

-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.

SELECT  products.name, catalogs.name
	FROM 
		products
	RIGHT JOIN 
		catalogs
	ON products.catalog_id = catalogs.id;

-- второй вариан решения

-- SELECT id, name, (SELECT name FROM catalogs WHERE id = products.catalog_id) AS catalogs FROM products;

/* SELECT id, name, catalog_id  FROM products; 
цифры catalog_id таблицы продуктов нужно преровнять к id, catalogs где храняться называния разделов*/



