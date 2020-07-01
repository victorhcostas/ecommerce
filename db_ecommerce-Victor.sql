-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 01-Jul-2020 às 21:31
-- Versão do servidor: 10.1.38-MariaDB
-- versão do PHP: 7.3.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_ecommerce`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addresses_save` (`pidaddress` INT(11), `pidperson` INT(11), `pdesaddress` VARCHAR(128), `pdescomplement` VARCHAR(32), `pdescity` VARCHAR(32), `pdesstate` VARCHAR(32), `pdescountry` VARCHAR(32), `pdeszipcode` CHAR(8), `pdesdistrict` VARCHAR(32))  BEGIN

	IF pidaddress > 0 THEN
		
		UPDATE tb_addresses
        SET
			idperson = pidperson,
            desaddress = pdesaddress,
            descomplement = pdescomplement,
            descity = pdescity,
            desstate = pdesstate,
            descountry = pdescountry,
            deszipcode = pdeszipcode, 
            desdistrict = pdesdistrict
		WHERE idaddress = pidaddress;
        
    ELSE
		
		INSERT INTO tb_addresses (idperson, desaddress, descomplement, descity, desstate, descountry, deszipcode, desdistrict)
        VALUES(pidperson, pdesaddress, pdescomplement, pdescity, pdesstate, pdescountry, pdeszipcode, pdesdistrict);
        
        SET pidaddress = LAST_INSERT_ID();
        
    END IF;
    
    SELECT * FROM tb_addresses WHERE idaddress = pidaddress;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_carts_save` (`pidcart` INT, `pdessessionid` VARCHAR(64), `piduser` INT, `pdeszipcode` CHAR(8), `pvlfreight` DECIMAL(10,2), `pnrdays` INT)  BEGIN

    IF pidcart > 0 THEN
        
        UPDATE tb_carts
        SET
            dessessionid = pdessessionid,
            iduser = piduser,
            deszipcode = pdeszipcode,
            vlfreight = pvlfreight,
            nrdays = pnrdays
        WHERE idcart = pidcart;
        
    ELSE
        
        INSERT INTO tb_carts (dessessionid, iduser, deszipcode, vlfreight, nrdays)
        VALUES(pdessessionid, piduser, pdeszipcode, pvlfreight, pnrdays);
        
        SET pidcart = LAST_INSERT_ID();
        
    END IF;
    
    SELECT * FROM tb_carts WHERE idcart = pidcart;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_categories_save` (`pidcategory` INT, `pdescategory` VARCHAR(64))  BEGIN
	
	IF pidcategory > 0 THEN
		
		UPDATE tb_categories
        SET descategory = pdescategory
        WHERE idcategory = pidcategory;
        
    ELSE
		
		INSERT INTO tb_categories (descategory) VALUES(pdescategory);
        
        SET pidcategory = LAST_INSERT_ID();
        
    END IF;
    
    SELECT * FROM tb_categories WHERE idcategory = pidcategory;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_orders_save` (`pidorder` INT, `pidcart` INT(11), `piduser` INT(11), `pidstatus` INT(11), `pidaddress` INT(11), `pvltotal` DECIMAL(10,2))  BEGIN
	
	IF pidorder > 0 THEN
		
		UPDATE tb_orders
        SET
			idcart = pidcart,
            iduser = piduser,
            idstatus = pidstatus,
            idaddress = pidaddress,
            vltotal = pvltotal
		WHERE idorder = pidorder;
        
    ELSE
    
		INSERT INTO tb_orders (idcart, iduser, idstatus, idaddress, vltotal)
        VALUES(pidcart, piduser, pidstatus, pidaddress, pvltotal);
		
		SET pidorder = LAST_INSERT_ID();
        
    END IF;
    
    SELECT * 
    FROM tb_orders a
    INNER JOIN tb_ordersstatus b USING(idstatus)
    INNER JOIN tb_carts c USING(idcart)
    INNER JOIN tb_users d ON d.iduser = a.iduser
    INNER JOIN tb_addresses e USING(idaddress)
    WHERE idorder = pidorder;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_products_save` (`pidproduct` INT(11), `pdesproduct` VARCHAR(64), `pvlprice` DECIMAL(10,2), `pvlwidth` DECIMAL(10,2), `pvlheight` DECIMAL(10,2), `pvllength` DECIMAL(10,2), `pvlweight` DECIMAL(10,2), `pdesurl` VARCHAR(128))  BEGIN
	
	IF pidproduct > 0 THEN
		
		UPDATE tb_products
        SET 
			desproduct = pdesproduct,
            vlprice = pvlprice,
            vlwidth = pvlwidth,
            vlheight = pvlheight,
            vllength = pvllength,
            vlweight = pvlweight,
            desurl = pdesurl
        WHERE idproduct = pidproduct;
        
    ELSE
		
		INSERT INTO tb_products (desproduct, vlprice, vlwidth, vlheight, vllength, vlweight, desurl) 
        VALUES(pdesproduct, pvlprice, pvlwidth, pvlheight, pvllength, pvlweight, pdesurl);
        
        SET pidproduct = LAST_INSERT_ID();
        
    END IF;
    
    SELECT * FROM tb_products WHERE idproduct = pidproduct;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_userspasswordsrecoveries_create` (`piduser` INT, `pdesip` VARCHAR(45))  BEGIN
	
	INSERT INTO tb_userspasswordsrecoveries (iduser, desip)
    VALUES(piduser, pdesip);
    
    SELECT * FROM tb_userspasswordsrecoveries
    WHERE idrecovery = LAST_INSERT_ID();
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usersupdate_save` (`piduser` INT, `pdesperson` VARCHAR(64), `pdeslogin` VARCHAR(64), `pdespassword` VARCHAR(256), `pdesemail` VARCHAR(128), `pnrphone` BIGINT, `pinadmin` TINYINT)  BEGIN
	
    DECLARE vidperson INT;
    
	SELECT idperson INTO vidperson
    FROM tb_users
    WHERE iduser = piduser;
    
    UPDATE tb_persons
    SET 
		desperson = pdesperson,
        desemail = pdesemail,
        nrphone = pnrphone
	WHERE idperson = vidperson;
    
    UPDATE tb_users
    SET
		deslogin = pdeslogin,
        despassword = pdespassword,
        inadmin = pinadmin
	WHERE iduser = piduser;
    
    SELECT * FROM tb_users a INNER JOIN tb_persons b USING(idperson) WHERE a.iduser = piduser;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_users_delete` (`piduser` INT)  BEGIN
	
    DECLARE vidperson INT;
    
	SELECT idperson INTO vidperson
    FROM tb_users
    WHERE iduser = piduser;
    
    DELETE FROM tb_users WHERE iduser = piduser;
    DELETE FROM tb_persons WHERE idperson = vidperson;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_users_save` (`pdesperson` VARCHAR(64), `pdeslogin` VARCHAR(64), `pdespassword` VARCHAR(256), `pdesemail` VARCHAR(128), `pnrphone` BIGINT, `pinadmin` TINYINT)  BEGIN
	
    DECLARE vidperson INT;
    
	INSERT INTO tb_persons (desperson, desemail, nrphone)
    VALUES(pdesperson, pdesemail, pnrphone);
    
    SET vidperson = LAST_INSERT_ID();
    
    INSERT INTO tb_users (idperson, deslogin, despassword, inadmin)
    VALUES(vidperson, pdeslogin, pdespassword, pinadmin);
    
    SELECT * FROM tb_users a INNER JOIN tb_persons b USING(idperson) WHERE a.iduser = LAST_INSERT_ID();
    
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_addresses`
--

CREATE TABLE `tb_addresses` (
  `idaddress` int(11) NOT NULL,
  `idperson` int(11) NOT NULL,
  `desaddress` varchar(128) NOT NULL,
  `descomplement` varchar(32) DEFAULT NULL,
  `descity` varchar(32) NOT NULL,
  `desstate` varchar(32) NOT NULL,
  `descountry` varchar(32) NOT NULL,
  `deszipcode` char(8) NOT NULL,
  `desdistrict` varchar(32) NOT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_addresses`
--

INSERT INTO `tb_addresses` (`idaddress`, `idperson`, `desaddress`, `descomplement`, `descity`, `desstate`, `descountry`, `deszipcode`, `desdistrict`, `dtregister`) VALUES
(1, 1, 'Rua OdÃ­lio Olinto de Almeida', 'Ao lado do Cemiterio Velho', 'Inhumas', 'GO', 'Brasil', '75400480', 'Centro', '2020-07-01 16:35:56'),
(2, 1, 'Rua OdÃ­lio Olinto de Almeida', '', 'Inhumas', 'GO', 'Brasil', '75400480', 'Centro', '2020-07-01 18:23:01'),
(3, 1, 'Rua OdÃ­lio Olinto de Almeida', '', 'Inhumas', 'GO', 'Brasil', '75400480', 'Centro', '2020-07-01 18:34:57'),
(4, 21, 'Rua OdÃ­lio Olinto de Almeida', 'Aqui do lado', 'Inhumas', 'GO', 'Brasil', '75400480', 'Centro', '2020-07-01 18:38:41'),
(5, 21, 'Rua OdÃ­lio Olinto de Almeida', '', 'Inhumas', 'GO', 'Brasil', '75400480', 'Centro', '2020-07-01 18:43:35'),
(6, 21, 'Rua OdÃ­lio Olinto de Almeida', '', 'Inhumas', 'GO', 'Brasil', '75400480', 'Centro', '2020-07-01 18:43:57'),
(7, 21, 'Rua OdÃ­lio Olinto de Almeida', '', 'Inhumas', 'GO', 'Brasil', '75400480', 'Centro', '2020-07-01 18:45:45'),
(8, 21, 'Rua OdÃ­lio Olinto de Almeida', '', 'Inhumas', 'GO', 'Brasil', '75400480', 'Centro', '2020-07-01 18:51:37'),
(9, 15, 'Rua 226', '', 'GoiÃ¢nia', 'GO', 'Brasil', '74610130', 'Setor Leste UniversitÃ¡rio', '2020-07-01 19:01:03'),
(10, 15, 'Rua 226', '', 'GoiÃ¢nia', 'GO', 'Brasil', '74610130', 'Setor Leste UniversitÃ¡rio', '2020-07-01 19:13:27'),
(11, 21, 'Rua 226', '', 'GoiÃ¢nia', 'GO', 'Brasil', '74610130', 'Setor Leste UniversitÃ¡rio', '2020-07-01 19:28:02'),
(12, 21, 'Rua 226', '', 'GoiÃ¢nia', 'GO', 'Brasil', '74610130', 'Setor Leste UniversitÃ¡rio', '2020-07-01 19:28:49');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_carts`
--

CREATE TABLE `tb_carts` (
  `idcart` int(11) NOT NULL,
  `dessessionid` varchar(64) NOT NULL,
  `iduser` int(11) DEFAULT NULL,
  `deszipcode` char(8) DEFAULT NULL,
  `vlfreight` decimal(10,2) DEFAULT NULL,
  `nrdays` int(11) DEFAULT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_carts`
--

INSERT INTO `tb_carts` (`idcart`, `dessessionid`, `iduser`, `deszipcode`, `vlfreight`, `nrdays`, `dtregister`) VALUES
(1, 'tttb1h64728lrp3en0h53j6946', 1, NULL, NULL, NULL, '2020-06-27 13:44:41'),
(2, 'vg7bmtfc3ke7c97jmr6ea9cpl6', NULL, '75400480', '120.02', 8, '2020-06-29 11:04:54'),
(3, '5q3sfefta7g8c3e8iq1g9uftia', NULL, '75400480', '0.00', 0, '2020-06-29 17:07:41'),
(4, 'mot4s34pdbq6mffqdilmvkp89s', NULL, '75400480', '188.40', 8, '2020-06-30 11:21:22'),
(5, 'g8m37ovp53f7abft25n1ed059u', NULL, '75400480', '223.12', 8, '2020-07-01 10:40:26'),
(6, 'ehe24292kvor8sl7vpvjoils90', NULL, '74610130', '120.02', 4, '2020-07-01 10:41:38');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_cartsproducts`
--

CREATE TABLE `tb_cartsproducts` (
  `idcartproduct` int(11) NOT NULL,
  `idcart` int(11) NOT NULL,
  `idproduct` int(11) NOT NULL,
  `dtremoved` datetime DEFAULT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_cartsproducts`
--

INSERT INTO `tb_cartsproducts` (`idcartproduct`, `idcart`, `idproduct`, `dtremoved`, `dtregister`) VALUES
(1, 2, 1, '2020-06-29 13:24:00', '2020-06-29 16:20:52'),
(2, 2, 1, '2020-06-29 14:11:38', '2020-06-29 16:24:09'),
(3, 2, 2, '2020-06-29 13:25:07', '2020-06-29 16:24:50'),
(4, 2, 3, '2020-06-29 13:25:51', '2020-06-29 16:25:16'),
(5, 2, 3, '2020-06-29 13:25:51', '2020-06-29 16:25:20'),
(6, 3, 1, '2020-06-29 15:07:08', '2020-06-29 17:07:54'),
(7, 2, 1, '2020-06-29 15:43:56', '2020-06-29 18:06:44'),
(8, 2, 1, '2020-06-29 16:28:44', '2020-06-29 18:40:54'),
(9, 2, 1, '2020-06-29 16:28:44', '2020-06-29 18:43:31'),
(10, 3, 4, '2020-06-29 15:45:28', '2020-06-29 18:44:36'),
(11, 3, 4, '2020-06-29 15:45:30', '2020-06-29 18:44:56'),
(12, 3, 3, '2020-06-29 15:47:08', '2020-06-29 18:45:38'),
(13, 3, 1, '2020-06-29 15:47:55', '2020-06-29 18:47:12'),
(14, 3, 1, '2020-06-29 15:47:55', '2020-06-29 18:47:20'),
(15, 3, 2, '2020-06-29 15:48:13', '2020-06-29 18:47:52'),
(16, 3, 13, '2020-06-29 16:07:20', '2020-06-29 18:48:11'),
(17, 3, 1, '2020-06-29 15:55:26', '2020-06-29 18:48:26'),
(18, 3, 1, '2020-06-29 15:58:26', '2020-06-29 18:48:40'),
(19, 3, 1, '2020-06-29 15:58:51', '2020-06-29 18:58:21'),
(20, 3, 1, '2020-06-29 16:07:19', '2020-06-29 18:58:49'),
(21, 3, 1, '2020-06-29 16:07:19', '2020-06-29 19:03:05'),
(22, 3, 1, '2020-06-29 16:11:29', '2020-06-29 19:10:21'),
(23, 3, 1, '2020-06-29 16:21:59', '2020-06-29 19:11:03'),
(24, 3, 1, '2020-06-29 16:23:06', '2020-06-29 19:21:50'),
(25, 3, 1, '2020-06-29 16:23:06', '2020-06-29 19:22:01'),
(26, 3, 1, '2020-06-29 16:23:06', '2020-06-29 19:22:03'),
(27, 3, 3, '2020-06-29 16:24:14', '2020-06-29 19:23:32'),
(28, 3, 1, '2020-06-29 16:26:07', '2020-06-29 19:24:18'),
(29, 3, 13, '2020-06-29 16:26:09', '2020-06-29 19:25:25'),
(30, 3, 12, '2020-06-29 16:26:11', '2020-06-29 19:25:29'),
(31, 3, 9, '2020-06-29 16:26:13', '2020-06-29 19:25:37'),
(32, 3, 2, '2020-06-29 16:28:24', '2020-06-29 19:25:44'),
(33, 3, 2, NULL, '2020-06-29 19:28:33'),
(34, 2, 2, '2020-06-29 16:29:02', '2020-06-29 19:28:48'),
(35, 2, 2, '2020-06-29 16:29:02', '2020-06-29 19:28:59'),
(36, 2, 7, '2020-06-29 16:30:18', '2020-06-29 19:29:05'),
(37, 2, 2, '2020-06-29 16:31:58', '2020-06-29 19:30:23'),
(38, 2, 2, '2020-06-29 16:33:06', '2020-06-29 19:31:45'),
(39, 2, 2, '2020-06-29 16:33:06', '2020-06-29 19:32:55'),
(40, 2, 1, NULL, '2020-06-29 19:33:11'),
(41, 4, 1, NULL, '2020-06-30 11:23:03'),
(42, 4, 1, NULL, '2020-06-30 11:23:14'),
(43, 5, 1, '2020-07-01 11:15:17', '2020-07-01 10:43:10'),
(44, 6, 1, '2020-07-01 16:22:42', '2020-07-01 10:45:57'),
(45, 6, 1, '2020-07-01 16:22:42', '2020-07-01 10:53:22'),
(46, 5, 1, '2020-07-01 15:34:39', '2020-07-01 14:03:36'),
(47, 5, 3, '2020-07-01 11:16:22', '2020-07-01 14:13:32'),
(48, 5, 3, NULL, '2020-07-01 14:16:02'),
(49, 5, 1, NULL, '2020-07-01 18:34:35'),
(50, 6, 1, '2020-07-01 16:23:24', '2020-07-01 19:23:03'),
(51, 6, 1, NULL, '2020-07-01 19:24:54');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_categories`
--

CREATE TABLE `tb_categories` (
  `idcategory` int(11) NOT NULL,
  `descategory` varchar(32) NOT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_categories`
--

INSERT INTO `tb_categories` (`idcategory`, `descategory`, `dtregister`) VALUES
(28, 'Xaomi', '2020-06-24 16:52:28'),
(29, 'Apple', '2020-06-24 17:17:33'),
(31, 'Motorola', '2020-06-24 18:10:18'),
(32, 'Samsung', '2020-06-24 18:22:43'),
(33, 'Smartphones e Tablets', '2020-06-26 13:42:29');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_orders`
--

CREATE TABLE `tb_orders` (
  `idorder` int(11) NOT NULL,
  `idcart` int(11) NOT NULL,
  `iduser` int(11) NOT NULL,
  `idstatus` int(11) NOT NULL,
  `idaddress` int(11) NOT NULL,
  `vltotal` decimal(10,2) NOT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_ordersstatus`
--

CREATE TABLE `tb_ordersstatus` (
  `idstatus` int(11) NOT NULL,
  `desstatus` varchar(32) NOT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_ordersstatus`
--

INSERT INTO `tb_ordersstatus` (`idstatus`, `desstatus`, `dtregister`) VALUES
(1, 'Em Aberto', '2017-03-13 03:00:00'),
(2, 'Aguardando Pagamento', '2017-03-13 03:00:00'),
(3, 'Pago', '2017-03-13 03:00:00'),
(4, 'Entregue', '2017-03-13 03:00:00');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_persons`
--

CREATE TABLE `tb_persons` (
  `idperson` int(11) NOT NULL,
  `desperson` varchar(64) NOT NULL,
  `desemail` varchar(128) DEFAULT NULL,
  `nrphone` bigint(20) DEFAULT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_persons`
--

INSERT INTO `tb_persons` (`idperson`, `desperson`, `desemail`, `nrphone`, `dtregister`) VALUES
(1, 'JoÃ£o Rangel', 'admin@hcode.com.br', 2147483647, '2017-03-01 03:00:00'),
(11, 'Vitao Teste', 'vhcsteste02@gmail.com', 62988997766, '2020-06-23 12:45:40'),
(13, 'Lucas Sidnei', 'nerosidnei@gmail.com', 62984887443, '2020-06-24 12:31:01'),
(14, 'Ttales', 'ttalessoft@gmail.com', 62985881122, '2020-06-24 13:12:14'),
(15, 'BÃ¢tÃ¡tÃ Ã§Ã£o', 'batata21@gmail.com', 62985784994, '2020-06-30 15:50:15'),
(16, 'Ã‡Ã£oÃ‡Ã£o', 'cao@auau.com', 62988776655, '2020-06-30 16:14:17'),
(20, 'teste1', 'teste@hotmail.com', 654321, '2020-06-30 18:07:19'),
(21, 'Jin', 'vhcsteste@gmail.com', 982828484, '2020-07-01 11:00:31');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_products`
--

CREATE TABLE `tb_products` (
  `idproduct` int(11) NOT NULL,
  `desproduct` varchar(64) NOT NULL,
  `vlprice` decimal(10,2) NOT NULL,
  `vlwidth` decimal(10,2) NOT NULL,
  `vlheight` decimal(10,2) NOT NULL,
  `vllength` decimal(10,2) NOT NULL,
  `vlweight` decimal(10,2) NOT NULL,
  `desurl` varchar(128) NOT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_products`
--

INSERT INTO `tb_products` (`idproduct`, `desproduct`, `vlprice`, `vlwidth`, `vlheight`, `vllength`, `vlweight`, `desurl`, `dtregister`) VALUES
(1, 'iPhone XR 64GB Branco Tela 6.1â€ iOS 12 4G 12MP - Apple', '3419.05', '7.50', '15.00', '7.50', '0.43', 'iphonexr-64gb', '2017-03-13 03:00:00'),
(2, 'Smart TV LED Samsung 50\" UHD 4K', '2359.90', '60.00', '80.00', '20.00', '7.00', 'smarttv-led-4k', '2017-03-13 03:00:00'),
(3, 'MacBook Pro i5, Tela Retina 13\", Touch Bar, SSD 256, 8GB - Prata', '4000.00', '21.24', '1.49', '30.41', '2.98', 'notebook-14-4gb-1tb', '2017-03-13 03:00:00'),
(4, 'Ipad 32GB Wi-Fi Tela 9,7\" CÃ¢mera 8MP Prata - Apple', '2499.99', '0.75', '16.95', '24.50', '0.47', 'ipad-32gb', '2020-06-25 11:47:06'),
(7, 'Smartphone Motorola Moto G5 Plus', '1135.23', '0.70', '15.20', '7.40', '0.16', 'smartphone-motorola-moto-g5-plus', '2020-06-25 17:02:32'),
(8, 'Smartphone Moto Z Play', '1887.78', '1.16', '14.10', '0.90', '0.13', 'smartphone-moto-z-play', '2020-06-25 17:02:32'),
(9, 'Smartphone Samsung Galaxy J5 Pro', '1299.00', '0.80', '14.60', '7.10', '0.16', 'smartphone-samsung-galaxy-j5', '2020-06-25 17:02:32'),
(10, 'Smartphone Samsung Galaxy J7 Prime', '1149.00', '15.10', '7.50', '0.80', '0.16', 'smartphone-samsung-galaxy-j7', '2020-06-25 17:02:32'),
(11, 'Smartphone Samsung Galaxy J3 Dual', '679.90', '14.20', '7.10', '0.70', '0.14', 'smartphone-samsung-galaxy-j3', '2020-06-25 17:02:32'),
(12, 'Redmi Note 9 - Xaomi', '3612.75', '15.60', '7.43', '0.88', '0.19', 'redminote9', '2020-06-25 17:55:27'),
(13, 'Mi True Wireless Earbuds Basic - Xaomi', '229.99', '2.16', '2.67', '1.64', '0.09', 'miearbuds', '2020-06-25 18:04:50');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_productscategories`
--

CREATE TABLE `tb_productscategories` (
  `idcategory` int(11) NOT NULL,
  `idproduct` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_productscategories`
--

INSERT INTO `tb_productscategories` (`idcategory`, `idproduct`) VALUES
(28, 12),
(28, 13),
(29, 1),
(29, 3),
(29, 4),
(31, 7),
(31, 8),
(32, 2),
(32, 9),
(32, 10),
(32, 11),
(33, 1),
(33, 4),
(33, 7),
(33, 8),
(33, 9),
(33, 10),
(33, 11),
(33, 12);

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_users`
--

CREATE TABLE `tb_users` (
  `iduser` int(11) NOT NULL,
  `idperson` int(11) NOT NULL,
  `deslogin` varchar(64) NOT NULL,
  `despassword` varchar(256) NOT NULL,
  `inadmin` tinyint(4) NOT NULL DEFAULT '0',
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_users`
--

INSERT INTO `tb_users` (`iduser`, `idperson`, `deslogin`, `despassword`, `inadmin`, `dtregister`) VALUES
(1, 1, 'admin', '$2y$12$YlooCyNvyTji8bPRcrfNfOKnVMmZA9ViM2A3IpFjmrpIbp5ovNmga', 1, '2017-03-13 03:00:00'),
(11, 11, 'vhcsteste', '$2y$12$jbrr6HZgLIW5dDZNIL2XaOAFXcCQRwKW40YFdnb78M27L9DoAax8O', 1, '2020-06-23 12:45:40'),
(13, 13, 'magal', '$2y$12$uSAUGoeYlKcXTNbMrJ0f1uQ3W4ccpvAJdpE8dp3RMs54oAKTr1bVq', 1, '2020-06-24 12:31:01'),
(14, 14, 'Ttales', '$2y$12$WkMMOeKQWY2LZttNl6DEtuOIW1COdgw8li20pKlkWmHrEp/uDNMtS', 1, '2020-06-24 13:12:14'),
(15, 15, 'batata', '$2y$12$dFznpQIM7dQZ32Vh6aMJm.RVP7y7SSPUTtkyJub1QvXKuyou0Gar6', 1, '2020-06-30 15:50:15'),
(16, 16, 'cao', '$2y$12$H67riK0mwIdVa8zd.IB0hezCsvkTFJS5TgCFHQyp3w9IN/s4E0Xfi', 1, '2020-06-30 16:14:17'),
(20, 20, 'teste', '$2y$12$PyFREpq4d3Z.3xWSKLHYK.PsePQ2ZoK349Aa/3zL7aJiA3neS9Y/y', 1, '2020-06-30 18:07:19'),
(21, 21, 'vhcsteste@gmail.com', '$2y$12$INtASCQSvh573chkt./.7uxYYM/bZkm/zUqmSn.3YSyxiVDKnXgTu', 0, '2020-07-01 11:00:31');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_userslogs`
--

CREATE TABLE `tb_userslogs` (
  `idlog` int(11) NOT NULL,
  `iduser` int(11) NOT NULL,
  `deslog` varchar(128) NOT NULL,
  `desip` varchar(45) NOT NULL,
  `desuseragent` varchar(128) NOT NULL,
  `dessessionid` varchar(64) NOT NULL,
  `desurl` varchar(128) NOT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tb_userspasswordsrecoveries`
--

CREATE TABLE `tb_userspasswordsrecoveries` (
  `idrecovery` int(11) NOT NULL,
  `iduser` int(11) NOT NULL,
  `desip` varchar(45) NOT NULL,
  `dtrecovery` datetime DEFAULT NULL,
  `dtregister` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tb_userspasswordsrecoveries`
--

INSERT INTO `tb_userspasswordsrecoveries` (`idrecovery`, `iduser`, `desip`, `dtrecovery`, `dtregister`) VALUES
(1, 11, '127.0.0.1', '2020-06-24 09:55:09', '2020-06-24 12:54:54'),
(2, 14, '127.0.0.1', NULL, '2020-06-24 13:13:47'),
(3, 21, '127.0.0.1', '2020-07-01 08:45:14', '2020-07-01 11:44:25');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tb_addresses`
--
ALTER TABLE `tb_addresses`
  ADD PRIMARY KEY (`idaddress`),
  ADD KEY `fk_addresses_persons_idx` (`idperson`);

--
-- Indexes for table `tb_carts`
--
ALTER TABLE `tb_carts`
  ADD PRIMARY KEY (`idcart`),
  ADD KEY `FK_carts_users_idx` (`iduser`);

--
-- Indexes for table `tb_cartsproducts`
--
ALTER TABLE `tb_cartsproducts`
  ADD PRIMARY KEY (`idcartproduct`),
  ADD KEY `FK_cartsproducts_carts_idx` (`idcart`),
  ADD KEY `FK_cartsproducts_products_idx` (`idproduct`);

--
-- Indexes for table `tb_categories`
--
ALTER TABLE `tb_categories`
  ADD PRIMARY KEY (`idcategory`);

--
-- Indexes for table `tb_orders`
--
ALTER TABLE `tb_orders`
  ADD PRIMARY KEY (`idorder`),
  ADD KEY `FK_orders_users_idx` (`iduser`),
  ADD KEY `fk_orders_ordersstatus_idx` (`idstatus`),
  ADD KEY `fk_orders_carts_idx` (`idcart`),
  ADD KEY `fk_orders_addresses_idx` (`idaddress`);

--
-- Indexes for table `tb_ordersstatus`
--
ALTER TABLE `tb_ordersstatus`
  ADD PRIMARY KEY (`idstatus`);

--
-- Indexes for table `tb_persons`
--
ALTER TABLE `tb_persons`
  ADD PRIMARY KEY (`idperson`);

--
-- Indexes for table `tb_products`
--
ALTER TABLE `tb_products`
  ADD PRIMARY KEY (`idproduct`);

--
-- Indexes for table `tb_productscategories`
--
ALTER TABLE `tb_productscategories`
  ADD PRIMARY KEY (`idcategory`,`idproduct`),
  ADD KEY `fk_productscategories_products_idx` (`idproduct`);

--
-- Indexes for table `tb_users`
--
ALTER TABLE `tb_users`
  ADD PRIMARY KEY (`iduser`),
  ADD KEY `FK_users_persons_idx` (`idperson`);

--
-- Indexes for table `tb_userslogs`
--
ALTER TABLE `tb_userslogs`
  ADD PRIMARY KEY (`idlog`),
  ADD KEY `fk_userslogs_users_idx` (`iduser`);

--
-- Indexes for table `tb_userspasswordsrecoveries`
--
ALTER TABLE `tb_userspasswordsrecoveries`
  ADD PRIMARY KEY (`idrecovery`),
  ADD KEY `fk_userspasswordsrecoveries_users_idx` (`iduser`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tb_addresses`
--
ALTER TABLE `tb_addresses`
  MODIFY `idaddress` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `tb_carts`
--
ALTER TABLE `tb_carts`
  MODIFY `idcart` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `tb_cartsproducts`
--
ALTER TABLE `tb_cartsproducts`
  MODIFY `idcartproduct` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT for table `tb_categories`
--
ALTER TABLE `tb_categories`
  MODIFY `idcategory` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `tb_orders`
--
ALTER TABLE `tb_orders`
  MODIFY `idorder` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tb_ordersstatus`
--
ALTER TABLE `tb_ordersstatus`
  MODIFY `idstatus` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `tb_persons`
--
ALTER TABLE `tb_persons`
  MODIFY `idperson` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `tb_products`
--
ALTER TABLE `tb_products`
  MODIFY `idproduct` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `tb_users`
--
ALTER TABLE `tb_users`
  MODIFY `iduser` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `tb_userslogs`
--
ALTER TABLE `tb_userslogs`
  MODIFY `idlog` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tb_userspasswordsrecoveries`
--
ALTER TABLE `tb_userspasswordsrecoveries`
  MODIFY `idrecovery` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Limitadores para a tabela `tb_addresses`
--
ALTER TABLE `tb_addresses`
  ADD CONSTRAINT `fk_addresses_persons` FOREIGN KEY (`idperson`) REFERENCES `tb_persons` (`idperson`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_carts`
--
ALTER TABLE `tb_carts`
  ADD CONSTRAINT `fk_carts_users` FOREIGN KEY (`iduser`) REFERENCES `tb_users` (`iduser`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_cartsproducts`
--
ALTER TABLE `tb_cartsproducts`
  ADD CONSTRAINT `fk_cartsproducts_carts` FOREIGN KEY (`idcart`) REFERENCES `tb_carts` (`idcart`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_cartsproducts_products` FOREIGN KEY (`idproduct`) REFERENCES `tb_products` (`idproduct`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_orders`
--
ALTER TABLE `tb_orders`
  ADD CONSTRAINT `fk_orders_addresses` FOREIGN KEY (`idaddress`) REFERENCES `tb_addresses` (`idaddress`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_orders_carts` FOREIGN KEY (`idcart`) REFERENCES `tb_carts` (`idcart`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_orders_ordersstatus` FOREIGN KEY (`idstatus`) REFERENCES `tb_ordersstatus` (`idstatus`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_orders_users` FOREIGN KEY (`iduser`) REFERENCES `tb_users` (`iduser`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_productscategories`
--
ALTER TABLE `tb_productscategories`
  ADD CONSTRAINT `fk_productscategories_categories` FOREIGN KEY (`idcategory`) REFERENCES `tb_categories` (`idcategory`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_productscategories_products` FOREIGN KEY (`idproduct`) REFERENCES `tb_products` (`idproduct`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_users`
--
ALTER TABLE `tb_users`
  ADD CONSTRAINT `fk_users_persons` FOREIGN KEY (`idperson`) REFERENCES `tb_persons` (`idperson`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_userslogs`
--
ALTER TABLE `tb_userslogs`
  ADD CONSTRAINT `fk_userslogs_users` FOREIGN KEY (`iduser`) REFERENCES `tb_users` (`iduser`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `tb_userspasswordsrecoveries`
--
ALTER TABLE `tb_userspasswordsrecoveries`
  ADD CONSTRAINT `fk_userspasswordsrecoveries_users` FOREIGN KEY (`iduser`) REFERENCES `tb_users` (`iduser`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
