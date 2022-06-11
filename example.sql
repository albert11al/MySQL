/*2. Создайте базу данных example, разместите в ней таблицу users, 
состоящую из двух столбцов, числового id и строкового name.*/

-- cmd создали базу данных 
CREATE DATABASE example;
-- из списка выбрали нашу созданную БД
USE EXAMPLE;
-- в файле sql создана таблица БД даже если она не сушествует
CREATE TABLE IF NOT EXISTS users (
	id INT PRIMARY KEY,
	name VARCHAR(255)
);
-- cmd выполняем команду и убеждаемся, что табл создан
-- SOURCE example.sql
-- инстукцией ESCRIBE users; убеждаемся, что это наша табл.

