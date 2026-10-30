drop database sales_coffe;

create database sales_coffe;

use sales_coffe;

CREATE TABLE sales_coffe (
    Transaction_ID VARCHAR(15) PRIMARY KEY,
    Item VARCHAR(50),
	Quantity DECIMAL(5,1),
    Price_Per_Unit DECIMAL(10,2),
    Total_Spent DECIMAL(10,2),
    Payment_Method VARCHAR(30),
    Location VARCHAR(30),
    Transaction_Date DATE
);

SELECT *
FROM sales_coffe;

USE sales_coffe;

CREATE TABLE items (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    nombre_item VARCHAR(30) UNIQUE
);
INSERT INTO items (nombre_item)
SELECT DISTINCT Item FROM sales_coffe;

CREATE TABLE metodos_pago (
    id_metodo INT AUTO_INCREMENT PRIMARY KEY,
    metodo_pago VARCHAR(30) UNIQUE
);
INSERT INTO metodos_pago (metodo_pago)
SELECT DISTINCT payment_Method FROM sales_coffe;

CREATE TABLE ubicaciones (
    id_ubicacion INT AUTO_INCREMENT PRIMARY KEY,
    ubicacion VARCHAR(30) UNIQUE
);
INSERT INTO ubicaciones (ubicacion)
SELECT DISTINCT `Location` FROM sales_coffe;

SELECT *
FROM ubicaciones;

#creamos la tabla puente 
CREATE TABLE transacciones (
    transaction_id VARCHAR(15) PRIMARY KEY,
    id_item INT,
    id_metodo INT,
    id_ubicacion INT,
    cantidad DECIMAL(5,1),
    precio_unitario DECIMAL(10,2),
    total DECIMAL(10,2),
    fecha DATE,
    FOREIGN KEY (id_item) REFERENCES items(id_item),
    FOREIGN KEY (id_metodo) REFERENCES metodos_pago(id_metodo),
    FOREIGN KEY (id_ubicacion) REFERENCES ubicaciones(id_ubicacion)
);

INSERT INTO transacciones
SELECT s.Transaction_ID, i.id_item, m.id_metodo, u.id_ubicacion,
       s.Quantity, s.Price_Per_Unit, s.Total_Spent, s.Transaction_Date
FROM sales_coffe s
JOIN items i ON s.Item = i.nombre_item
JOIN metodos_pago m ON s.Payment_Method = m.metodo_pago
JOIN ubicaciones u ON s.Location = u.ubicacion;


SELECT *
FROM transacciones;

#Ventas por productos
SELECT i.nombre_item, SUM(t.total) AS ventas,
   ROUND(SUM(t.total) * 100.0 /(SELECT SUM(total) FROM transacciones),2) AS porcentaje_participacion
FROM transacciones t
JOIN items i ON t.id_item = i.id_item
GROUP BY i.nombre_item
ORDER BY ventas DESC;

SELECT i.nombre_item,
       SUM(t.cantidad)        AS unidades_vendidas,
       MAX(t.precio_unitario) AS precio_unitario
FROM transacciones t
JOIN items i ON t.id_item = i.id_item
GROUP BY i.nombre_item
ORDER BY unidades_vendidas DESC;

#ventas por mes y método de pago

SELECT v.mes, v.metodo_pago,v.ventas,
      ROW_NUMBER() OVER (PARTITION BY v.mes ORDER BY v.ventas DESC) AS ranking
FROM (SELECT
        DATE_FORMAT(t.fecha, '%Y-%m') AS mes,
        m.metodo_pago,
        SUM(t.total) AS ventas
    FROM transacciones t
    JOIN metodos_pago m
        ON t.id_metodo = m.id_metodo
    GROUP BY
        DATE_FORMAT(t.fecha, '%Y-%m'),
        m.metodo_pago) AS v
ORDER BY v.mes, ranking;

#Ventas por ubicación y producto (tres tablas juntas):

SELECT u.ubicacion, i.nombre_item, SUM(t.total) AS ventas,
       ROW_NUMBER() OVER (PARTITION BY u.ubicacion ORDER BY SUM(t.total) DESC) AS Ranking
FROM transacciones t
JOIN ubicaciones u ON t.id_ubicacion = u.id_ubicacion
JOIN items i ON t.id_item = i.id_item
GROUP BY u.ubicacion, i.nombre_item
ORDER BY u.ubicacion, ventas DESC;

SELECT i.nombre_item,
       SUM(t.cantidad)        AS unidades_vendidas,
       MAX(t.precio_unitario) AS precio_unitario
FROM transacciones t
JOIN items i ON t.id_item = i.id_item
GROUP BY i.nombre_item
ORDER BY unidades_vendidas DESC;