use a_shop;

-- ***********************************************************************************
-- Тригеры
-- ***********************************************************************************

/*  ===== Создадим таблицу logs типа Archive. Пусть при каждом создании записи в таблицах
 users, catalogs и products в таблицу logs помещается время и дата создания записи,
 название таблицы, идентификатор первичного ключа и содержимое поля name ===== */

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
tablename VARCHAR(255) NOT NULL COMMENT 'Название таблицы',
extenal_id INT NOT NULL COMMENT 'Первичный ключ таблицы tablename',
name VARCHAR(255) NOT NULL COMMENT 'Поле name таблицы tablename',
created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE = Archive;

--  ===== Триггер для таблицы users ===== 
CREATE TRIGGER log_after_insert_to_users 
AFTER INSERT 
ON users FOR EACH ROW 
BEGIN
	INSERT INTO logs (tablename, extenal_id, name) VALUES('users', NEW.id, NEW.lastname);
END

--  ===== Триггер для таблицы Products ===== 
CREATE TRIGGER log_after_insert_to_products 
AFTER INSERT 
ON products FOR EACH ROW 
BEGIN
	INSERT INTO logs (tablename, extenal_id, name) VALUES('products', NEW.id, NEW.name);
END

--  ===== Триггер для таблицы Catalogs ===== 
CREATE TRIGGER log_after_insert_to_catalogs
AFTER INSERT 
ON catalogs FOR EACH ROW 
BEGIN
	INSERT INTO logs (tablename, extenal_id, name) VALUES('catalogs', NEW.id, NEW.cat_name);
END

-- -----------------------------------------------------------------------------------
INSERT INTO users (id, lastname, email) VALUES
	(NULL, 'kolya', '78eed93@example.net');

INSERT INTO catalogs VALUES 	
	(NULL, 'Sale');
	
INSERT INTO products (id, name, goods_catid) VALUES
	(NULL, 'Sweaters', 13);

SELECT * FROM logs;
-- -----------------------------------------------------------------------------------

-- ***********************************************************************************
-- хранимые процедуры 
-- ***********************************************************************************

/*  ===== 1. Создать хранимую процедуру, которая выведет покупателей, оформивших заказы, по диапазонам. 
Если аргумент имеет значение «Маленькая суммы», то диапазон продаж от 0 до 15000, 
«Средние суммы» — от 15000 до 45000, «Большие суммы» — свыше 45000 ===== */

CREATE PROCEDURE a_shop.get_users(str VARCHAR(45))
BEGIN
    CASE str
    WHEN "Маленькие суммы"
    THEN
        SELECT CONCAT(users.firstname,' ', users.lastname) as "Имя покупателя", SUM(orders_products.quantity * products.price) as "Сумма покупки"
        FROM users
        INNER JOIN orders_products on users.id = orders_products.orders_id
        INNER JOIN products on orders_products.goods_id = products.id 
        GROUP BY users.id
        HAVING SUM(orders_products.quantity * products.price) < 15000;
    WHEN "Средние суммы"
    THEN
        SELECT CONCAT(users.firstname,' ', users.lastname) as "Имя покупателя", SUM(orders_products.quantity * products.price) as "Сумма покупки"
        FROM users
        INNER JOIN orders_products on users.id = orders_products.orders_id
        INNER JOIN products on orders_products.goods_id = products.id 
        GROUP BY users.id
        HAVING SUM(orders_products.quantity * products.price) >= 15000 and SUM(orders_products.quantity * products.price) < 45000;
    WHEN "Большие суммы"
    THEN
        SELECT CONCAT(users.firstname,' ', users.lastname) as "Имя покупателя", SUM(orders_products.quantity * products.price) as "Сумма покупки"
        FROM users
        INNER JOIN orders_products on users.id = orders_products.orders_id
        INNER JOIN products on orders_products.goods_id = products.id 
        GROUP BY users.id
        HAVING SUM(orders_products.quantity * products.price) >= 45000;
    END CASE;
END

-- -----------------------------------------------------------------------------------
-- Вызвать созданную процедуру можно с тремя различными аргументами:
CALL get_users("Маленькие суммы");		-- от-15000
CALL get_users("Средние суммы");		-- 15000-45000
CALL get_users("Большие суммы");		-- 45000-до
-- -----------------------------------------------------------------------------------

/*  ===== 2. Создать хранимую процедуру, которая отобразит информацию о товаре 
 и стоимость товаров которое укажет пользователь в заданных аргументах т.е "от и до" =====  */


CREATE PROCEDURE a_shop.info_products(arg1 int, arg2 int)
BEGIN
    SELECT name, description, price
    FROM products
    WHERE price > arg1 and price < arg2;
END 

-- -----------------------------------------------------------------------------------
CALL info_products(0,1500);
-- -----------------------------------------------------------------------------------

-- ***********************************************************************************
-- представления 
-- ***********************************************************************************

--  ===== 1. Создать представления которая отображает количество заказов в зависимости от возраста по 10 лет ===== 

CREATE OR REPLACE VIEW orders_for_age_groups AS
SELECT 
	CASE
		WHEN TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) >=1 AND TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) <=4 THEN '1-4'
		WHEN TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) >=5 AND TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) <=9 THEN '5-9'
    	WHEN TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) >=10 AND TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) <=20 THEN '10-20'
    	WHEN TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) >=21 AND TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) <=30 THEN '21-30'
    	WHEN TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) >=31 AND TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) <=40 THEN '31-40'
    	WHEN TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) >=41 AND TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) <=50 THEN '41-50'
    	WHEN TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) >=51 AND TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) <=60 THEN '51-60'
    	WHEN TIMESTAMPDIFF(YEAR, p.birthday_at, NOW()) >=61 THEN '61+'
	END AS ageband,
	(SUM(op.quantity)) AS number_orders,
	user_id, 
	birthday_at
FROM 
	profiles AS p
LEFT JOIN
	orders_products AS op 
ON p.user_id = op.orders_id
GROUP BY user_id
ORDER BY birthday_at DESC;

-- -----------------------------------------------------------------------------------
-- вызов представления 
SELECT*FROM orders_for_age_groups;
-- -----------------------------------------------------------------------------------

/*  ===== 2. Создайте представление, которое выводит название name товарной позиции из таблицы products 
и соответствующее название каталога name из таблицы catalogs ===== */

CREATE OR REPLACE VIEW products_catalogs 
	AS
SELECT products.name as name_product, catalogs.cat_name as name_catalog 
	FROM under_catalog
JOIN catalogs 
	ON under_catalog.catalog_id = catalogs.id
JOIN products
	ON under_catalog.id = products.goods_catid;

-- -----------------------------------------------------------------------------------
-- Обратимся к представлению
SELECT * FROM products_catalogs;
-- -----------------------------------------------------------------------------------

 




