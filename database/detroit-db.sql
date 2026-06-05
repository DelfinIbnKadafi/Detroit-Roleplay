SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+07:00";

CREATE TABLE `Pemain` (
  `id` int(11) NOT NULL,
  `nama` varchar(24) NOT NULL,
  `verified` int(11) DEFAULT '0',
  `kode` int(11) DEFAULT NULL,
  `sandi` varchar(90) DEFAULT NULL,
  `gender` tinyint(4) DEFAULT NULL,
  `skin` smallint(6) DEFAULT '1',
  `posx` float DEFAULT NULL,
  `posy` float DEFAULT NULL,
  `posz` float DEFAULT NULL,
  `angle` float DEFAULT NULL,
  `interior` int(11) DEFAULT '0',
  `virtualworld` int(11) NOT NULL DEFAULT '0',
  `darah` float DEFAULT NULL,
  `armor` float DEFAULT NULL,
  `level` smallint(6) DEFAULT '1',
  `uang` int DEFAULT '0',
  `lapar` int DEFAULT '100',
  `haus` int DEFAULT '100'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `Pemain`
  ADD PRIMARY KEY (`id`);

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
  `health` float DEFAULT '100.0',
  `x` float DEFAULT '0.0',
  `y` float DEFAULT '0.0',
  `z` float DEFAULT '0.0',
  `angel` float DEFAULT '0.0',
  `fuel` int DEFAULT '0',
  `kunci` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `Kendaraan`
  ADD PRIMARY KEY (`vid`);