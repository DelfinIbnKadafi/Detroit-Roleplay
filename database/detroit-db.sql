-- Import ke database kosong yang digunakan oleh gamemode dan Discord Bot
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET NAMES utf8mb4;
SET time_zone = '+07:00';

CREATE TABLE `Pemain` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `discordid` varchar(128) NOT NULL,
  `nama` varchar(24) NOT NULL,
  `verified` tinyint(1) NOT NULL DEFAULT '0',
  `kode` int(11) DEFAULT NULL,
  `sandi` varchar(90) DEFAULT NULL,
  `admin` int NOT NULL DEFAULT '0',
  `gender` tinyint(4) NOT NULL DEFAULT '0',
  `skin` smallint(6) NOT NULL DEFAULT '1',
  `posx` float NOT NULL DEFAULT '1743.06',
  `posy` float NOT NULL DEFAULT '-1862.50',
  `posz` float NOT NULL DEFAULT '13.57',
  `angle` float NOT NULL DEFAULT '3.34',
  `interior` int(11) NOT NULL DEFAULT '0',
  `virtualworld` int(11) NOT NULL DEFAULT '0',
  `darah` float NOT NULL DEFAULT '100.0',
  `armor` float NOT NULL DEFAULT '0.0',
  `level` smallint(6) NOT NULL DEFAULT '1',
  `uang` int NOT NULL DEFAULT '0',
  `bank` int NOT NULL DEFAULT '0',
  `norek` int NOT NULL DEFAULT '123456789',
  `phone` int NOT NULL DEFAULT '0',
  `phonestatus` int NOT NULL DEFAULT '0',
  `nohp` varchar(16) NOT NULL DEFAULT '',
  `ktp` int NOT NULL DEFAULT '0',
  `job` int NOT NULL DEFAULT '0',
  `lapar` int NOT NULL DEFAULT '100',
  `haus` int NOT NULL DEFAULT '100',
  `tanggallahir` varchar(64) NOT NULL DEFAULT 'None',
  `death` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pemain_discordid` (`discordid`),
  UNIQUE KEY `uq_pemain_nama` (`nama`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `Kendaraan` (
  `vid` int(11) NOT NULL AUTO_INCREMENT,
  `pid` int(11) NOT NULL,
  `model` int(11) NOT NULL,
  `color1` int(11) NOT NULL DEFAULT '0',
  `color2` int(11) NOT NULL DEFAULT '0',
  `plate` varchar(16) NOT NULL DEFAULT '',
  `health` float NOT NULL DEFAULT '1000.0',
  `x` float NOT NULL DEFAULT '0.0',
  `y` float NOT NULL DEFAULT '0.0',
  `z` float NOT NULL DEFAULT '0.0',
  `angel` float NOT NULL DEFAULT '0.0',
  `fuel` int NOT NULL DEFAULT '0',
  `kunci` int NOT NULL DEFAULT '0',
  `death` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`vid`),
  KEY `idx_kendaraan_pid` (`pid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `atm` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `posx` float NOT NULL,
  `posy` float NOT NULL,
  `posz` float NOT NULL,
  `angle` float NOT NULL,
  `cadangan` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `atm` (`id`, `posx`, `posy`, `posz`, `angle`, `cadangan`) VALUES
(1, 1739.22, -1863.56, 13.2372, 179.68, 1000000),
(2, 1746.95, -1863.51, 13.209, -179.365, 1009999),
(3, 905.298, -1467.55, 2753.98, 89.3048, 1000000),
(4, 1454.92, -1755.54, 13.2169, 179.566, 1000000),
(5, 1172.08, -1328.1, 15.0397, 87.5041, 1000000);


CREATE TABLE `bussines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `ownerid` int(11) NOT NULL DEFAULT '0',
  `posx` float NOT NULL,
  `posy` float NOT NULL,
  `posz` float NOT NULL,
  `type` tinyint NOT NULL,
  `stock` int NOT NULL DEFAULT '100',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
