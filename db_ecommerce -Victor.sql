-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 04-Jul-2020 às 15:13
-- Versão do servidor: 10.1.38-MariaDB
-- versão do PHP: 7.3.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `db_ecommerce`
--

DELIMITER $$
--
-- Procedures
--
CREATE PROCEDURE `sp_addresses_save` (`pidaddress` INT(11), `pidperson` INT(11), `pdesaddress` VARCHAR(128), `pdesnumber` VARCHAR(16), `pdescomplement` VARCHAR(32), `pdescity` VARCHAR(32), `pdesstate` VARCHAR(32), `pdescountry` VARCHAR(32), `pdeszipcode` CHAR(8), `pdesdistrict` VARCHAR(32))  BEGIN

	IF pidaddress > 0 THEN
		
		UPDATE tb_addresses
        SET
			idperson = pidperson,
            desaddress = pdesaddress,
            desnumber = pdesnumber,
            descomplement = pdescomplement,
            descity = pdescity,
            desstate = pdesstate,
            descountry = pdescountry,
            deszipcode = pdeszipcode, 
            desdistrict = pdesdistrict
		WHERE idaddress = pidaddress;
        
    ELSE
		
		INSERT INTO tb_addresses (idperson, desaddress, desnumber, descomplement, descity, desstate, descountry, deszipcode, desdistrict)
        VALUES(pidperson, pdesaddress, pdesnumber, pdescomplement, pdescity, pdesstate, pdescountry, pdeszipcode, pdesdistrict);
        
        SET pidaddress = LAST_INSERT_ID();
        
    END IF;
    
    SELECT * FROM tb_addresses WHERE idaddress = pidaddress;

END$$

CREATE PROCEDURE `sp_carts_save` (`pidcart` INT, `pdessessionid` VARCHAR(64), `piduser` INT, `pdeszipcode` CHAR(8), `pvlfreight` DECIMAL(10,2), `pnrdays` INT)  BEGIN

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

CREATE PROCEDURE `sp_categories_save` (`pidcategory` INT, `pdescategory` VARCHAR(64))  BEGIN
	
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

CREATE PROCEDURE `sp_orders_save` (`pidorder` INT, `pidcart` INT(11), `piduser` INT(11), `pidstatus` INT(11), `pidaddress` INT(11), `pvltotal` DECIMAL(10,2))  BEGIN
	
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

CREATE PROCEDURE `sp_products_save` (`pidproduct` INT(11), `pdesproduct` VARCHAR(64), `pvlprice` DECIMAL(10,2), `pvlwidth` DECIMAL(10,2), `pvlheight` DECIMAL(10,2), `pvllength` DECIMAL(10,2), `pvlweight` DECIMAL(10,2), `pdesurl` VARCHAR(128))  BEGIN
	
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

CREATE PROCEDURE `sp_userspasswordsrecoveries_create` (`piduser` INT, `pdesip` VARCHAR(45))  BEGIN
	
	INSERT INTO tb_userspasswordsrecoveries (iduser, desip)
    VALUES(piduser, pdesip);
    
    SELECT * FROM tb_userspasswordsrecoveries
    WHERE idrecovery = LAST_INSERT_ID();
    
END$$

CREATE PROCEDURE `sp_usersupdate_save` (`piduser` INT, `pdesperson` VARCHAR(64), `pdeslogin` VARCHAR(64), `pdespassword` VARCHAR(256), `pdesemail` VARCHAR(128), `pnrphone` BIGINT, `pinadmin` TINYINT)  BEGIN
	
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

CREATE PROCEDURE `sp_users_delete` (`piduser` INT)  BEGIN
    
    DECLARE vidperson INT;
    
    SET FOREIGN_KEY_CHECKS = 0;
	
	SELECT idperson INTO vidperson
    FROM tb_users
    WHERE iduser = piduser;
	
    DELETE FROM tb_addresses WHERE idperson = vidperson;
    DELETE FROM tb_addresses WHERE idaddress IN(SELECT idaddress FROM tb_orders WHERE iduser = piduser);
	DELETE FROM tb_persons WHERE idperson = vidperson;
    
    DELETE FROM tb_userslogs WHERE iduser = piduser;
    DELETE FROM tb_userspasswordsrecoveries WHERE iduser = piduser;
    DELETE FROM tb_orders WHERE iduser = piduser;
    DELETE FROM tb_cartsproducts WHERE idcart IN(SELECT idcart FROM tb_carts WHERE iduser = piduser);
    DELETE FROM tb_carts WHERE iduser = piduser;
    DELETE FROM tb_users WHERE iduser = piduser;
    
    SET FOREIGN_KEY_CHECKS = 1;
    
END$$

CREATE PROCEDURE `sp_users_save` (`pdesperson` VARCHAR(64), `pdeslogin` VARCHAR(64), `pdespassword` VARCHAR(256), `pdesemail` VARCHAR(128), `pnrphone` BIGINT, `pinadmin` TINYINT)  BEGIN
	
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
  `desnumber` varchar(16) NOT NULL,
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
(15, 'BÃ¢tÃ¡tÃ Ã§Ã£o', 'batata21@gmail.com', 62985784994, '2020-06-30 15:50:15'),
(16, 'Ã‡Ã£oÃ‡Ã£o', 'cao@auau.com', 62988776655, '2020-06-30 16:14:17'),
(20, 'teste1', 'teste@hotmail.com', 654321, '2020-06-30 18:07:19');

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
(15, 15, 'batata', '$2y$12$dFznpQIM7dQZ32Vh6aMJm.RVP7y7SSPUTtkyJub1QvXKuyou0Gar6', 1, '2020-06-30 15:50:15'),
(16, 16, 'cao', '$2y$12$EiQ2JCspPYI11EczKW1Zn.M61bb738V5k6soI22P59bh2Ofk1Fl56', 1, '2020-06-30 16:14:17'),
(20, 20, 'teste', '$2y$12$PyFREpq4d3Z.3xWSKLHYK.PsePQ2ZoK349Aa/3zL7aJiA3neS9Y/y', 1, '2020-06-30 18:07:19');

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
(3, 21, '127.0.0.1', '2020-07-01 08:45:14', '2020-07-01 11:44:25'),
(4, 23, '127.0.0.1', NULL, '2020-07-03 19:10:26'),
(5, 21, '127.0.0.1', NULL, '2020-07-04 10:53:06'),
(6, 21, '127.0.0.1', NULL, '2020-07-04 11:04:12'),
(7, 21, '127.0.0.1', NULL, '2020-07-04 11:13:04'),
(8, 21, '127.0.0.1', NULL, '2020-07-04 11:15:36'),
(9, 21, '127.0.0.1', NULL, '2020-07-04 11:18:52'),
(10, 21, '127.0.0.1', NULL, '2020-07-04 11:22:34'),
(11, 21, '127.0.0.1', '2020-07-04 08:27:57', '2020-07-04 11:24:11'),
(12, 21, '127.0.0.1', '2020-07-04 08:32:27', '2020-07-04 11:32:05');

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
  MODIFY `idaddress` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `tb_carts`
--
ALTER TABLE `tb_carts`
  MODIFY `idcart` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `tb_cartsproducts`
--
ALTER TABLE `tb_cartsproducts`
  MODIFY `idcartproduct` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT for table `tb_categories`
--
ALTER TABLE `tb_categories`
  MODIFY `idcategory` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `tb_orders`
--
ALTER TABLE `tb_orders`
  MODIFY `idorder` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `tb_ordersstatus`
--
ALTER TABLE `tb_ordersstatus`
  MODIFY `idstatus` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `tb_persons`
--
ALTER TABLE `tb_persons`
  MODIFY `idperson` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `tb_products`
--
ALTER TABLE `tb_products`
  MODIFY `idproduct` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `tb_users`
--
ALTER TABLE `tb_users`
  MODIFY `iduser` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `tb_userslogs`
--
ALTER TABLE `tb_userslogs`
  MODIFY `idlog` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tb_userspasswordsrecoveries`
--
ALTER TABLE `tb_userspasswordsrecoveries`
  MODIFY `idrecovery` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

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

