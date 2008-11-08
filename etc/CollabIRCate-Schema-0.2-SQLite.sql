-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Sat Nov  8 03:03:08 2008
-- 
BEGIN TRANSACTION;


--
-- Table: channel
--
DROP TABLE channel;
CREATE TABLE channel (
  name text NOT NULL,
  description text,
  PRIMARY KEY (id)
);


--
-- Table: channel_report
--
DROP TABLE channel_report;
CREATE TABLE channel_report (
  users_id integer(4) NOT NULL,
  channel_id integer(4) NOT NULL,
  report_expires timestamp without time zone(8),
  report_frequency text,
  report_last timestamp without time zone(8),
  PRIMARY KEY (users_id, channel_id)
);


--
-- Table: log
--
DROP TABLE log;
CREATE TABLE log (
  ts timestamp without time zone(8) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  channel_id integer(4) NOT NULL,
  users_id integer(4) NOT NULL,
  type text NOT NULL,
  entry text NOT NULL,
  PRIMARY KEY (id)
);


--
-- Table: tag
--
DROP TABLE tag;
CREATE TABLE tag (
  name text,
  log_id integer(4) NOT NULL,
  PRIMARY KEY (id)
);


--
-- Table: user
--
DROP TABLE user;
CREATE TABLE user (
  email text,
  PRIMARY KEY (user_id)
);


--
-- Table: users
--
DROP TABLE users;
CREATE TABLE users (
  email text,
  PRIMARY KEY (id)
);


COMMIT;
