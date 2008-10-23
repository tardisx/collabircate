--
-- Table: channel
--
DROP TABLE channel CASCADE;
CREATE TABLE channel (
  channel_id smallint DEFAULT 'nextval('channel_channel_id_seq'::regclass)' NOT NULL,
  name text NOT NULL,
  description text,
  PRIMARY KEY (channel_id)
);



--
-- Table: channel_report
--
DROP TABLE channel_report CASCADE;
CREATE TABLE channel_report (
  user_id smallint NOT NULL,
  channel_id smallint NOT NULL,
  report_expires timestamp without time zone(6),
  report_frequency text,
  report_last timestamp without time zone(6),
  PRIMARY KEY (user_id, channel_id)
);



--
-- Table: log
--
DROP TABLE log CASCADE;
CREATE TABLE log (
  log_id smallint DEFAULT 'nextval('log_log_id_seq'::regclass)' NOT NULL,
  ts timestamp without time zone(6) DEFAULT now() NOT NULL,
  channel_id smallint NOT NULL,
  user_id smallint NOT NULL,
  type text NOT NULL,
  entry text NOT NULL,
  PRIMARY KEY (log_id)
);



--
-- Table: tag
--
DROP TABLE tag CASCADE;
CREATE TABLE tag (
  tag_id smallint DEFAULT 'nextval('tag_tag_id_seq'::regclass)' NOT NULL,
  name text,
  log_id smallint NOT NULL,
  PRIMARY KEY (tag_id)
);



--
-- Table: users
--
DROP TABLE users CASCADE;
CREATE TABLE users (
  user_id smallint DEFAULT 'nextval('users_user_id_seq'::regclass)' NOT NULL,
  email text,
  PRIMARY KEY (user_id)
);

--
-- Foreign Key Definitions
--

ALTER TABLE channel_report ADD FOREIGN KEY (channel_id)
  REFERENCES channel (channel_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE channel_report ADD FOREIGN KEY (user_id)
  REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE log ADD FOREIGN KEY (channel_id)
  REFERENCES channel (channel_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE log ADD FOREIGN KEY (user_id)
  REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE tag ADD FOREIGN KEY (log_id)
  REFERENCES log (log_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;
