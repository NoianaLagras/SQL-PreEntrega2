-- Creación de la base de datos
DROP DATABASE IF EXISTS PreEntrega2; 
CREATE DATABASE PreEntrega2;
USE PreEntrega2;

-- Creacion de las tablas

-- *****************************************************************************
--                                   TABLAS
-- *****************************************************************************


CREATE TABLE Clientes (
  id_client INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  client_name VARCHAR(100) NOT NULL,
  dni VARCHAR(20) NOT NULL,
  birthdate DATE,
  client_mail VARCHAR(100) NOT NULL,
  client_address VARCHAR(150) NOT NULL,
  INDEX(client_name)
);

CREATE TABLE Metodos_de_Pago (
  id_pay INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  method VARCHAR(50) NOT NULL,
  INDEX(method)
);

CREATE TABLE Pedidos (
  id_order INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  buy_date DATE NOT NULL,
  id_client INT NOT NULL,
  id_pay INT NOT NULL,
  total_order DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (id_client) REFERENCES Clientes(id_client),
  FOREIGN KEY (id_pay) REFERENCES Metodos_de_Pago(id_pay)
);

CREATE TABLE Categorias(
  id_categ INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  categ_name VARCHAR(30) NOT NULL,
  INDEX (categ_name)
);

CREATE TABLE Productos (
  id_prod INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  prod_name VARCHAR(100) NOT NULL,
  list_price DECIMAL(10, 2) NOT NULL,
  wholesale_price DECIMAL(10, 2),
  retail_price DECIMAL(10, 2),
  prod_desc VARCHAR(255),
  id_categ INT,
  stock INT NOT NULL,
  thumbnails VARCHAR(260),
  FOREIGN KEY (id_categ) REFERENCES Categorias(id_categ),
  INDEX(prod_name, prod_desc)
);

CREATE TABLE Detalles_del_pedido (
    id_order INT,
    id_prod INT,
    prod_quantity INT NOT NULL,
    prod_price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (id_order, id_prod),
    FOREIGN KEY (id_order) REFERENCES Pedidos (id_order),
    FOREIGN KEY (id_prod) REFERENCES Productos (id_prod)
);

-- Creacion de la tabla para registrar actualizaciones de stock
CREATE TABLE Updated_Stock (
    id_historial INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_prod INT NOT NULL,
    date_current TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    nuevo_stock INT NOT NULL,
    FOREIGN KEY (id_prod) REFERENCES Productos(id_prod)
);

-- *****************************************************************************
--                           INSERCION DE DATOS 
-- *****************************************************************************


-- Insercion de datos en la tabla Clientes
INSERT INTO Clientes (client_name, dni, birthdate, client_mail, client_address)
VALUES 
  ('Juan Perez', '12345678', '1980-04-10', 'juanperez@mail.com', 'Calle 123'),
  ('Maria Gomez', '87654321', '1990-06-25', 'mariagomez@mail.com', 'Calle 456'),
  ('Carlos Martinez', '11223344', '1985-08-15', 'carlosmartinez@mail.com', 'Calle 789');

-- Inserción de datos en la tabla Metodos_de_Pago
INSERT INTO Metodos_de_Pago (method)
VALUES 
  ('Tarjeta de Credito'),
  ('Transferencia Bancaria'),
  ('Mercado Pago');


-- Insercion de datos en la tabla Categorias
INSERT INTO Categorias (categ_name)
VALUES 
  ('Ropa masculina'),
  ('Ropa femenina'),
  ('Buzos');

-- Insercion de datos en la tabla Productos
INSERT INTO Productos (prod_name, list_price, wholesale_price, retail_price, prod_desc, id_categ, stock, thumbnails)
VALUES 
  ('Buzo Adidas', 6000.00, 7000.00, 9000.00, 'Buzo Adidas original', 3, 50, 'url_del_buzo'),
  ('Parka', 200.00, 250.00, 280.00, 'Tapado de invierno', 2, 200, 'url_del_tapado'),
  ('Camisa', 3000.00, 4000.00, 4500.00, 'Camisa blanca hombre', 1, 100, 'url_to_camisa');


-- Insercion de datos en la tabla Pedidos
INSERT INTO Pedidos (buy_date, id_client, id_pay, total_order)
VALUES 
  ('2024-01-10', 1, 1, 19500.00),  -- Juan Perez pago con tarjeta de credito
  ('2024-02-10', 1, 2, 250.00),  -- Juan Perez pago por transferencia bancaria
  ('2024-02-15', 2, 2, 6000.00),    -- Maria Gomez pago por transferencia bancaria
  ('2024-03-20', 3, 3, 4500.00);    -- Carlos Martinez pago por medio de mercado pago

-- Insercion de datos en la tabla Detalles_del_pedido
INSERT INTO Detalles_del_pedido (id_order, id_prod, prod_quantity, prod_price)
VALUES 
  (1, 1, 1, 9000.00),  -- Juan Perez compro 1 buzo addidas
  (1, 2, 5, 250.00),   -- Juan Perez tambien compro 5 parkas de mujer
  (2, 2, 2, 280.00),   -- Maria Gomez compro 2 parkas
  (3, 3, 10, 4000);   -- Carlos Martinez compro 10 camisas

-- *****************************************************************************
--                                 Consultas 
-- *****************************************************************************


-- SELECT * FROM Clientes
-- SELECT * FROM Productos
 -- SELECT * FROM Pedidos probar total order 
-- SELECT * FROM Detalles_del_pedido
SELECT client_name, client_address
FROM Clientes
WHERE client_address = 'Calle 123';

SELECT prod_name, list_price
FROM Productos
ORDER BY list_price ASC;

-- Simplificar pedidos usando de alias p y en Clientes usado de alias c 
SELECT p.id_order, c.client_name, p.buy_date
FROM Pedidos AS p
JOIN Clientes AS c ON p.id_client = c.id_client;

-- Consulta de precios en caso de que no tenga precio mayorista 
SELECT prod_name, wholesale_price AS price
FROM Productos
WHERE wholesale_price IS NOT NULL
UNION
SELECT prod_name, retail_price AS price
FROM Productos
WHERE retail_price IS NOT NULL;

-- Consulta por productos con el  mayor precio
SELECT prod_name, list_price
FROM Productos
WHERE list_price = (SELECT MAX(list_price) FROM Productos);

-- *****************************************************************************
--                              Fin de Consultas 
-- *****************************************************************************



-- *****************************************************************************
--                                 VISTAS
-- *****************************************************************************

-- Vista para ver los pedidos junto con el  cliente y el total de la orden
DROP VIEW IF EXISTS Vista_Pedido;
CREATE VIEW Vista_Pedido AS
SELECT p.id_order, c.client_name, p.buy_date, p.total_order
FROM Pedidos p
JOIN Clientes c ON p.id_client = c.id_client;

-- Vista para ver el stock por categoria
DROP VIEW IF EXISTS Vista_Stock;
CREATE VIEW Vista_Stock AS
SELECT p.prod_name, c.categ_name, p.stock
FROM Productos p
JOIN Categorias c ON p.id_categ = c.id_categ;

-- Vista para ver los detalles del pedido por cliente
DROP VIEW IF EXISTS Vista_PedidosCliente;
CREATE VIEW Vista_PedidosCliente AS
SELECT c.client_name, p.id_order, p.buy_date, p.total_order
FROM Pedidos p
JOIN Clientes c ON p.id_client = c.id_client;

-- Vista para ver los detalles del producto pedido 
DROP VIEW IF EXISTS Vista_DetallesPedidos;
CREATE VIEW Vista_DetallesPedidos AS
SELECT p.id_order, c.client_name, prod.prod_name, d.prod_quantity, d.prod_price
FROM Detalles_del_pedido d
JOIN Pedidos p ON d.id_order = p.id_order
JOIN Clientes c ON p.id_client = c.id_client
JOIN Productos prod ON d.id_prod = prod.id_prod;

-- Vista para ver el total de ventas y cantidades por categoria 
DROP VIEW IF EXISTS Vista_VentasCategoria;
CREATE VIEW Vista_VentasCategoria AS
SELECT cat.categ_name, SUM(d.prod_quantity) AS total_quantity, 
       SUM(d.prod_quantity * d.prod_price) AS total_sales
FROM Detalles_del_pedido d
JOIN Productos prod ON d.id_prod = prod.id_prod
JOIN Categorias cat ON prod.id_categ = cat.id_categ
GROUP BY cat.categ_name;



-- *****************************************************************************
--                                FUNCIONES 
-- *****************************************************************************




-- Funcion para ver total gastado por el cliente segun su ID
DELIMITER //

CREATE FUNCTION TotalGastadoPorCliente(client_id INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
  DECLARE total DECIMAL(10, 2);


  SELECT SUM(total_order) INTO total
  FROM Pedidos
  WHERE id_client = client_id;

  RETURN total;
END //

DELIMITER ;
SELECT TotalGastadoPorCliente(1);

-- Funcion para ver los pedidos que tiene el cliente segun su  ID
DELIMITER //
CREATE FUNCTION CantidadPedidosPorCliente(client_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total
  FROM Pedidos
  WHERE id_client = client_id;
  RETURN total;
END //
DELIMITER ;
SELECT CantidadPedidosPorCliente(1);


-- *****************************************************************************
--                                 STORED PROCEDURES
-- *****************************************************************************


DELIMITER //
CREATE PROCEDURE AgregarNuevoCliente(
  IN nombre VARCHAR(100),
  IN dni VARCHAR(20),
  IN nacimiento DATE,
  IN email VARCHAR(100),
  IN direccion VARCHAR(150)
)
BEGIN
  INSERT INTO Clientes (client_name, dni, birthdate, client_mail, client_address)
  VALUES (nombre, dni, nacimiento, email, direccion);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE ActualizarStockProducto(
  IN producto_id INT,
  IN nuevo_stock INT
)
BEGIN
  UPDATE Productos
  SET stock = nuevo_stock
  WHERE id_prod = producto_id;
END //
DELIMITER ;




-- *****************************************************************************
--                                TRIGGERS 
-- *****************************************************************************

DELIMITER //
CREATE TRIGGER ActualizarStockEnPedido
AFTER INSERT ON Detalles_del_pedido
FOR EACH ROW
BEGIN
  UPDATE Productos
  SET stock = stock - NEW.prod_quantity
  WHERE id_prod = NEW.id_prod;
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER RegistrarFechaActualizacionStock
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    IF NEW.stock != OLD.stock THEN
        INSERT INTO Updated_Stock (id_prod, nuevo_stock)
        VALUES (NEW.id_prod, NEW.stock);
    END IF;
END //
DELIMITER ;