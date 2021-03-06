-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Thu Oct 23 13:07:25 2008
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `channel`;
--
-- Table: `channel`
--
CREATE TABLE `channel` (
  `channel_id` integer(4) NOT NULL DEFAULT 'nextval('channel_channel_id_seq'::regclass)',
  `name` text NOT NULL,
  `description` text,
  PRIMARY KEY (`channel_id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `channel_report`;
--
-- Table: `channel_report`
--
CREATE TABLE `channel_report` (
  `user_id` integer(4) NOT NULL,
  `channel_id` integer(4) NOT NULL,
  `report_expires` timestamp without time zone(8),
  `report_frequency` text,
  `report_last` timestamp without time zone(8),
  INDEX (`channel_id`),
  INDEX (`user_id`),
  PRIMARY KEY (`user_id`, `channel_id`),
  CONSTRAINT `fk_channel_id` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `log`;
--
-- Table: `log`
--
CREATE TABLE `log` (
  `log_id` integer(4) NOT NULL DEFAULT 'nextval('log_log_id_seq'::regclass)',
  `ts` timestamp without time zone(8) NOT NULL DEFAULT 'now()',
  `channel_id` integer(4) NOT NULL,
  `user_id` integer(4) NOT NULL,
  `type` text NOT NULL,
  `entry` text NOT NULL,
  INDEX (`channel_id`),
  INDEX (`user_id`),
  PRIMARY KEY (`log_id`),
  CONSTRAINT `fk_channel_id_1` FOREIGN KEY (`channel_id`) REFERENCES `channel` (`channel_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_user_id_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `tag`;
--
-- Table: `tag`
--
CREATE TABLE `tag` (
  `tag_id` integer(4) NOT NULL DEFAULT 'nextval('tag_tag_id_seq'::regclass)',
  `name` text,
  `log_id` integer(4) NOT NULL,
  INDEX (`log_id`),
  PRIMARY KEY (`tag_id`),
  CONSTRAINT `fk_log_id` FOREIGN KEY (`log_id`) REFERENCES `log` (`log_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `users`;
--
-- Table: `users`
--
CREATE TABLE `users` (
  `user_id` integer(4) NOT NULL DEFAULT 'nextval('users_user_id_seq'::regclass)',
  `email` text,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB;

SET foreign_key_checks=1;

