DROP DATABASE IF EXISTS A_shop;
CREATE DATABASE A_shop;
USE A_shop;					               

-- ***********************************************************************************
-- таблица с именем покупателей  
-- ***********************************************************************************

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    firstname VARCHAR(100),
    lastname VARCHAR(100) COMMENT 'Фамилия', -- COMMENT на случай, если имя неочевидное
    email VARCHAR(100) UNIQUE, -- email unique т.к. будет использоваться еше как логин 
    password_hash VARCHAR(100),
    phone BIGINT, -- телефонный номер покупателя 
    INDEX users_firstname_lastname_idx(firstname, lastname)
);

-- ***********************************************************************************
-- профиль покупателя 
-- ***********************************************************************************

DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
	user_id SERIAL PRIMARY KEY,
    gender CHAR(1),
    birthday_at DATE, -- дата рождения покупателя. что бы потом делать им в этот день скидки
    address VARCHAR(100), -- поля для адреса доставки покупателя.
    created_at DATETIME DEFAULT NOW(), -- время посещения покупателя
    hometown VARCHAR(100)   -- родной город покупателя
);

ALTER TABLE profiles 
ADD CONSTRAINT fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE;

-- ***********************************************************************************   
-- табл. интернет магазина каталог:
-- ***********************************************************************************
   
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
	id SERIAL PRIMARY KEY, -- not null запрещает добавлять пустые значения
	cat_name VARCHAR(50),     -- имя для разделов каталога
	UNIQUE unique_name(cat_name(10)) /* апретим ставку разделов которые уже добавлены в таблб
для того чтобы не раздувать индексб индексируем 1-ые 10 синволов*/
);

-- ***********************************************************************************   
-- табл. с розделами интернет магазина под каталог:
-- ***********************************************************************************

DROP TABLE IF EXISTS under_catalog;
CREATE TABLE under_catalog (
	id SERIAL PRIMARY KEY, -- not null запрещает добавлять пустые значения
	name VARCHAR(50), -- имя для категории товаров
	catalog_id BIGINT UNSIGNED NOT NULL
	-- FOREIGN KEY (catalog_id) REFERENCES catalogs(id) ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE under_catalog 
ADD CONSTRAINT fk_catalog_id 
    FOREIGN KEY (catalog_id) REFERENCES catalogs(id)
    ON UPDATE CASCADE ON DELETE CASCADE;
   
-- ***********************************************************************************
-- таблица способа доставки
-- ***********************************************************************************
   
DROP TABLE IF EXISTS delivery;
CREATE TABLE delivery (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) -- поле варианта доставки
);

-- ***********************************************************************************
-- таблица товаров
-- ***********************************************************************************

DROP TABLE IF EXISTS products;
CREATE TABLE products (
	id SERIAL PRIMARY KEY,	
	name VARCHAR(100), --  Название товара
	description TEXT, -- описание товара
	goods_catid BIGINT UNSIGNED NOT NULL, -- поле будет хранить в себе ключ категории к которой принадлежит данный товар
	images VARCHAR(255), -- поле будет хранить в себе имя главной картинки товара (обложки).
	visible ENUM('0', '1') DEFAULT'1',-- поле будет отвечать за состояние товара, (видимы-невидимый) 0 - невидимый, 1 - видимый. По умолчанию - 1.
	hits ENUM('0', '1') DEFAULT'0',-- Если 1 - значит товар относится к «хитам продаж» иначе - 0 По умолчанию - 0.
	new ENUM('0', '1') DEFAULT'0',-- Если 1 - значит товар относится к «новинкам» иначе - 0 По умолчанию - 0.
	sale ENUM('0', '1') DEFAULT'0',-- Если 1 - значит товар относится к «товарам со скидкой» иначе - 0 По умолчанию - 0.
	price DECIMAL (11,2), -- цена товара
	data DATE COMMENT 'дата добавления товара',
	INDEX products_idx(id) -- быстрый поиск товара
	
);
 	
ALTER TABLE products 
ADD CONSTRAINT products_fk_goods_catid
	FOREIGN KEY (goods_catid) REFERENCES under_catalog(id) 
 	ON UPDATE CASCADE ON DELETE CASCADE;

-- ***********************************************************************************
-- таблица заказов
-- ***********************************************************************************
 
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	id SERIAL PRIMARY KEY,
	customer_id BIGINT UNSIGNED NOT NULL, -- покупатель
	delivery_id BIGINT UNSIGNED NOT NULL, -- способа доставки
	dates DATETIME DEFAULT NOW(), -- дата совершения заказа
	status BIGINT UNSIGNED NOT NULL DEFAULT'0', -- статус заказа, 0- в обработке, 1- заказ отправлен
	INDEX orders_idx(customer_id)  -- быстрый поиск заказа
);

ALTER TABLE orders 
ADD CONSTRAINT orders_fk_customer_id
	FOREIGN KEY (customer_id) REFERENCES profiles(user_id) 
	ON UPDATE CASCADE ON DELETE CASCADE,
ADD CONSTRAINT orders_fk_delivery_id
	FOREIGN KEY (delivery_id) REFERENCES delivery(id) 
	ON UPDATE CASCADE ON DELETE CASCADE;

-- *********************************************************************************** 
-- таблица заказанных товаров
-- ***********************************************************************************

DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
-- id SERIAL PRIMARY KEY,
	orders_id BIGINT UNSIGNED NOT NULL, -- ключ заказа
	goods_id BIGINT UNSIGNED NOT NULL,  -- ключ товара
	quantity BIGINT UNSIGNED NOT NULL,  -- количество заказанного товара
	PRIMARY KEY (orders_id, goods_id)
);

ALTER TABLE orders_products 
ADD CONSTRAINT orders_products_fk_orders_id
	FOREIGN KEY (orders_id) REFERENCES orders(id) 
	ON UPDATE CASCADE ON DELETE CASCADE,
ADD CONSTRAINT orders_products_fk_goods_id
	FOREIGN KEY (goods_id) REFERENCES products(id) 
	ON UPDATE CASCADE ON DELETE CASCADE;

-- ***********************************************************************************
-- таблица скидок
-- ***********************************************************************************

DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL, -- скидка пользователю в день рождения
	product_id BIGINT UNSIGNED NOT NULL, -- скидки на определенные товары
	discount FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
	started_at DATETIME COMMENT 'начала действия скидки', 
	finished_at DATETIME COMMENT 'конец действия скидки',
	/* вводим не ограниченное по времени скидки . если одно из полей принимает null то у интервала 
	 * нет ограниченй, если оба null то скидка без срочная */
	INDEX discounts_user_idx(user_id),
	INDEX discounts_product_idx(product_id)
);

ALTER TABLE discounts 
ADD CONSTRAINT discounts_fk_user_id
	FOREIGN KEY (user_id) REFERENCES profiles(user_id)
	ON UPDATE CASCADE ON DELETE CASCADE,
ADD CONSTRAINT discounts_fk_product_id
	FOREIGN KEY (product_id) REFERENCES products(id) 
	ON UPDATE CASCADE ON DELETE CASCADE;

-- ***********************************************************************************
-- таблица имя менеджера 
-- ***********************************************************************************

DROP TABLE IF EXISTS manager;
CREATE TABLE manager (
	id SERIAL PRIMARY KEY, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    firstname VARCHAR(100),
    lastname VARCHAR(100) COMMENT 'Фамилия', -- COMMENT на случай, если имя неочевидное
    email VARCHAR(100), -- email менеджера
    phone BIGINT -- телефонный номер покупателя 
);

-- ***********************************************************************************
-- таблица сообщений, связь между заказчиком и менеджером
-- ***********************************************************************************

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL primary key,
	from_user_id BIGINT UNSIGNED NOT NULL, -- Кто написал  сообшения от пользователя к менеджеру
	to_manager_id BIGINT UNSIGNED NOT NULL, -- Кому написал   сообшения менеджеру от пользователя
	body text, -- Текст сообщения
	created_at datetime DEFAULT NOW() -- Дата и время сообщения
);

ALTER TABLE messages 
ADD CONSTRAINT messages_fk_from_user_id
	FOREIGN KEY (from_user_id) REFERENCES users(id)
	ON UPDATE CASCADE ON DELETE CASCADE,
ADD CONSTRAINT messages_fk_to_manager_id
	FOREIGN KEY (to_manager_id) REFERENCES manager(id) 
	ON UPDATE CASCADE ON DELETE CASCADE;

-- ***********************************************************************************
-- таблица отзывов о товаре оставленный покупателями
-- ***********************************************************************************

DROP TABLE IF EXISTS comments;
CREATE TABLE comments (
	id SERIAL primary key,
	user_id BIGINT UNSIGNED NOT NULL, -- имя покупателя оставивший отзыв
	product_id BIGINT UNSIGNED NOT NULL, -- называния товар на которое оставили отзыв
	comment text, -- текст отзыва
	created_at DATE -- дата когда оставили отзыв
);

ALTER TABLE comments 
ADD CONSTRAINT comments_fk_user
	FOREIGN KEY (user_id) REFERENCES users(id)
	ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT comments_fk_product
	FOREIGN KEY (product_id) REFERENCES products(id)
	ON DELETE CASCADE ON UPDATE CASCADE;














