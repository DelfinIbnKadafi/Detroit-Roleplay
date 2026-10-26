SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+07:00";

CREATE TABLE `Pemain` (
  `id` int(11) NOT NULL,
  `discordid` varchar(128) NOT NULL,
  `nama` varchar(24) NOT NULL,
  `verified` int(11) DEFAULT '0',
  `kode` int(11) DEFAULT NULL,
  `sandi` varchar(90) DEFAULT NULL,
  `admin` int DEFAULT '0',
  `gender` tinyint(4) DEFAULT NULL,
  `skin` smallint(6) DEFAULT '1',
  `posx` float NOT NULL DEFAULT '1743.06',
  `posy` float NOT NULL DEFAULT '-1862.50',
  `posz` float NOT NULL DEFAULT '13.57',
  `angle` float NOT NULL DEFAULT '3.34',
  `interior` int(11) DEFAULT '0',
  `virtualworld` int(11) NOT NULL DEFAULT '0',
  `darah` float NOT NULL DEFAULT '100.0',
  `armor` float NOT NULL DEFAULT '0.0',
  `level` smallint(6) DEFAULT '1',
  `uang` int DEFAULT '0',
  `bank` int DEFAULT '0',
  `norek` int DEFAULT '123456789',
  `phone` int DEFAULT '0',
  `phonestatus` int DEFAULT '0',
  `nohp` varchar(16) NOT NULL DEFAULT '',
  `ktp` int DEFAULT '0',
  `job` int DEFAULT '0',
  `lapar` int DEFAULT '100',
  `haus` int DEFAULT '100',
  `tanggallahir` varchar(64) NOT NULL DEFAULT 'None',
  `death` boolean NOT NULL DEFAULT FALSE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `Pemain`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pemain_discordid` (`discordid`),
  ADD UNIQUE KEY `uq_pemain_nama` (`nama`);

ALTER TABLE `Pemain`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

CREATE TABLE `Kendaraan` (
  `vid` int(11) NOT NULL,
  `pid` int(11) NOT NULL,
  `model` int(11) NOT NULL,
  `color1` int(11) DEFAULT '0',
  `color2` int(11) DEFAULT '0',
  `plate` varchar(16),
  `health` float DEFAULT '1000.0',
  `x` float DEFAULT '0.0',
  `y` float DEFAULT '0.0',
  `z` float DEFAULT '0.0',
  `angel` float DEFAULT '0.0',
  `fuel` int DEFAULT '0',
  `kunci` int DEFAULT '0',
  `death` tinyint DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `Kendaraan`
  ADD PRIMARY KEY (`vid`),
  ADD KEY `idx_kendaraan_pid` (`pid`);

ALTER TABLE `Kendaraan`
  MODIFY `vid` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

CREATE TABLE `atm` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `posx` float NOT NULL,
  `posy` float NOT NULL,
  `posz` float NOT NULL,
  `angle` float NOT NULL,
  `cadangan` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `bussines` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `ownerid` int(11) NOT NULL DEFAULT '0',
  `posx` float NOT NULL,
  `posy` float NOT NULL,
  `posz` float NOT NULL,
  `type` tinyint NOT NULL,
  `stock` int DEFAULT 100,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
