CREATE DATABASE  IF NOT EXISTS `dev`;
USE `dev`;

SET NAMES utf8 ;

DROP TABLE IF EXISTS `fn`;

CREATE TABLE `fn`
(
  `useragent` varchar(255) NOT NULL,
  `type` tinyint(2) DEFAULT NULL,
  `date` datetime DEFAULT NULL
);