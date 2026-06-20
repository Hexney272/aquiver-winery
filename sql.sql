-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               11.8.3-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.7.0.6850
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table esxlegacy_cc6c3a.winery_barrel
CREATE TABLE IF NOT EXISTS `winery_barrel` (
  `id` int(11) NOT NULL,
  `durability` int(11) NOT NULL,
  `material` varchar(65) NOT NULL,
  `instance` int(11) NOT NULL,
  `content` longtext NOT NULL,
  `lockedState` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`,`instance`),
  KEY `FK_distillery_barrel_distillery_instance` (`instance`),
  CONSTRAINT `FK_distillery_barrel_distillery_instance` FOREIGN KEY (`instance`) REFERENCES `winery_instance` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table esxlegacy_cc6c3a.winery_instance
CREATE TABLE IF NOT EXISTS `winery_instance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `positionX` float NOT NULL DEFAULT 0,
  `positionY` float NOT NULL DEFAULT 0,
  `positionZ` float NOT NULL DEFAULT 0,
  `lockState` tinyint(4) NOT NULL,
  `price` int(11) NOT NULL,
  `ownership` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table esxlegacy_cc6c3a.winery_permission
CREATE TABLE IF NOT EXISTS `winery_permission` (
  `identifier` varchar(128) NOT NULL,
  `name` varchar(128) NOT NULL,
  `permissions` longtext NOT NULL,
  `instance` int(11) NOT NULL,
  PRIMARY KEY (`identifier`,`instance`),
  KEY `FK_distillery_permission_distillery_instance` (`instance`),
  CONSTRAINT `FK_distillery_permission_distillery_instance` FOREIGN KEY (`instance`) REFERENCES `winery_instance` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table esxlegacy_cc6c3a.winery_pressing_station
CREATE TABLE IF NOT EXISTS `winery_pressing_station` (
  `id` int(11) NOT NULL,
  `durability` decimal(5,2) NOT NULL,
  `instance` int(11) NOT NULL,
  PRIMARY KEY (`id`,`instance`) USING BTREE,
  KEY `FK_distillery_pressing_station_distillery_instance` (`instance`),
  CONSTRAINT `FK_distillery_pressing_station_distillery_instance` FOREIGN KEY (`instance`) REFERENCES `winery_instance` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table esxlegacy_cc6c3a.winery_warehouse
CREATE TABLE IF NOT EXISTS `winery_warehouse` (
  `id` varchar(64) NOT NULL,
  `instance` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  PRIMARY KEY (`id`,`instance`),
  KEY `FK_distillery_warehouse_distillery_instance` (`instance`),
  CONSTRAINT `FK_distillery_warehouse_distillery_instance` FOREIGN KEY (`instance`) REFERENCES `winery_instance` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

-- Dumping structure for table esxlegacy_cc6c3a.winery_wooden_barrel
CREATE TABLE IF NOT EXISTS `winery_wooden_barrel` (
  `id` int(11) NOT NULL,
  `durability` decimal(5,2) NOT NULL,
  `instance` int(11) NOT NULL,
  `material` varchar(64) NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`content`)),
  PRIMARY KEY (`id`,`instance`) USING BTREE,
  KEY `FK_distillery_wooden_barrel_distillery_instance` (`instance`),
  CONSTRAINT `FK_distillery_wooden_barrel_distillery_instance` FOREIGN KEY (`instance`) REFERENCES `winery_instance` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;