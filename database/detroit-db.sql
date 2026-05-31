SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+07:00";

-- --------------------------------------------------------
-- Tabel `pemain`
-- --------------------------------------------------------

CREATE TABLE `Pemain` (
  `id`          INT(11)      NOT NULL,
  `nama`        VARCHAR(24)  NOT NULL,
  `verified`    INT(11)      DEFAULT '0',
  `kode`        INT(11)      DEFAULT NULL,
  `sandi`       VARCHAR(90)  DEFAULT NULL,
  `gender`      TINYINT(4)   DEFAULT NULL,
  `skin`        SMALLINT(6)  DEFAULT '1',
  `posx`        FLOAT        DEFAULT NULL,
  `posy`        FLOAT        DEFAULT NULL,
  `posz`        FLOAT        DEFAULT NULL,
  `angle`       FLOAT        DEFAULT NULL,
  `interior`    INT(11)      DEFAULT '0',
  `virtualworld` INT(11)     NOT NULL DEFAULT '0',
  `darah`       FLOAT        DEFAULT NULL,
  `armor`       FLOAT        DEFAULT NULL,
  `level`       SMALLINT(6)  DEFAULT '1',
  `uang`        INT          DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `Pemain`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `Pemain`
  MODIFY `id` INT(11) NOT NULL AUTO_INCREMENT;

COMMIT;

-- --------------------------------------------------------
-- Tabel `kendaraan`
-- --------------------------------------------------------

CREATE TABLE `Kendaraan` (
  `vid`    INT(11) NOT NULL,
  `pid`    INT(11) NOT NULL,
  `model`  INT(11) NOT NULL,
  `color1` INT(11) DEFAULT '0',
  `color2` INT(11) DEFAULT '0',
  `health` FLOAT   DEFAULT '100.0',
  `x`      FLOAT   DEFAULT '0.0',
  `y`      FLOAT   DEFAULT '0.0',
  `z`      FLOAT   DEFAULT '0.0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `Kendaraan`
  ADD PRIMARY KEY (`vid`);