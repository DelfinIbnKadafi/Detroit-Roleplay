SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+07:00";

CREATE TABLE `pemain` (
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
  `level` smallint(6) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `pemain`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `pemain`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;