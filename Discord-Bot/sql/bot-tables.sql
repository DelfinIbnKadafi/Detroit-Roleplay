CREATE TABLE IF NOT EXISTS discord_bot_meta (
  name VARCHAR(64) NOT NULL PRIMARY KEY,
  value TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS discord_bot_tickets (
  guild_id VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  owner_id VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  channel_id VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  status ENUM('opening', 'open', 'closing') NOT NULL DEFAULT 'opening',
  subject VARCHAR(100) NOT NULL,
  description VARCHAR(1000) NOT NULL,
  opened_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (guild_id, owner_id),
  UNIQUE KEY uq_discord_ticket_channel (channel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS discord_bot_schema (
  id TINYINT NOT NULL PRIMARY KEY,
  version INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
