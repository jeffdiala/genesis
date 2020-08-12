

-- Adminer 4.7.7 MySQL dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

SET NAMES utf8mb4;

-- create the databases
DROP DATABASE IF EXISTS `db-project-001`;

CREATE DATABASE IF NOT EXISTS `db-project-001`;
USE `db-project-001`;


DROP TABLE IF EXISTS `channel`;
CREATE TABLE `channel` (
  `code` char(50) NOT NULL,
  `name` char(50) NOT NULL,
  `partial` tinyint(4) NOT NULL,
  `active` tinyint(4) NOT NULL,
  `create_by` char(50) DEFAULT NULL,
  `create_at` datetime DEFAULT NULL,
  `modified_by` char(50) DEFAULT NULL,
  `modified_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `channel` (`code`, `name`, `partial`, `active`, `create_by`, `create_at`, `modified_by`, `modified_at`) VALUES
('AG',	'Agent',	1,	1,	'system',	'2020-06-10 13:23:44',	'system',	'2020-06-10 13:23:44'),
('CC',	'Credit Card',	1,	1,	'system',	'2020-06-10 13:23:44',	'system',	'2020-06-10 13:23:44'),
('DD',	'Direct Debit',	1,	1,	'system',	'2020-06-10 13:23:44',	'system',	'2020-06-10 13:23:44');


-- 2020-06-10 09:34:34