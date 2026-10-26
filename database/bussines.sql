-- Jalankan jika database Detroit Roleplay belum memiliki tabel bussines
CREATE TABLE IF NOT EXISTS `bussines` (
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
