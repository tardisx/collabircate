-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Sat Nov  8 03:03:08 2008
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `channel`;
--
-- Table: `channel`
--
CREATE TABLE `channel` (
  `id` integer(4) NOT NULL DEFAULT 'nextval('channel_id_seq'::regclass)',
  `name` text NOT NULL,
  `description` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `channel_report`;
--
-- Table: `channel_report`
--
CREATE TABLE `channel_report` (
  `users_id` integer(4) NOT NULL,
  `channel_id` integer(4) NOT NULL,
  `report_expires` timestamp without time zone(8),
  `report_frequency` text,
  `report_last` timestamp without time zone(8),
  INDEX (`channel_id`),
  INDEX (`users_id`),
  PRIMARY KEY (`users_id`, `channel_id`),
  CONSTRAINT `fk_channel_id` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_users_id` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `log`;
--
-- Table: `log`
--
CREATE TABLE `log` (
  `id` integer(4) NOT NULL DEFAULT 'nextval('log_id_seq'::regclass)',
  `ts` timestamp without time zone(8) NOT NULL DEFAULT 'now()',
  `channel_id` integer(4) NOT NULL,
  `users_id` integer(4) NOT NULL,
  `type` text NOT NULL,
  `entry` text NOT NULL,
  INDEX (`channel_id`),
  INDEX (`users_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_channel_id_1` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_users_id_1` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `tag`;
--
-- Table: `tag`
--
CREATE TABLE `tag` (
  `id` integer(4) NOT NULL DEFAULT 'nextval('tag_id_seq'::regclass)',
  `name` text,
  `log_id` integer(4) NOT NULL,
  INDEX (`log_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_log_id` FOREIGN KEY (`log_id`) REFERENCES `log` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `user`;
--
-- Table: `user`
--
CREATE TABLE `user` (
  `user_id` integer(4) NOT NULL DEFAULT 'nextval('user_user_id_seq'::regclass)',
  `email` text,
  PRIMARY KEY (`user_id`)
);

DROP TABLE IF EXISTS `users`;
--
-- Table: `users`
--
CREATE TABLE `users` (
  `id` integer(4) NOT NULL DEFAULT 'nextval('users_id_seq'::regclass)',
  `email` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

SET foreign_key_checks=1;

