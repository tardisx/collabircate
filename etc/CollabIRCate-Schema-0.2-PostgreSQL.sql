--
-- Table: channel
--
DROP TABLE channel CASCADE;
CREATE TABLE channel (
  id smallint DEFAULT 'nextval('channel_id_seq'::regclass)' NOT NULL,
  name text NOT NULL,
  description text,
  PRIMARY KEY (id)
);



--
-- Table: channel_report
--
DROP TABLE channel_report CASCADE;
CREATE TABLE channel_report (
  users_id smallint NOT NULL,
  channel_id smallint NOT NULL,
  report_expires timestamp without time zone(6),
  report_frequency text,
  report_last timestamp without time zone(6),
  PRIMARY KEY (users_id, channel_id)
);



--
-- Table: log
--
DROP TABLE log CASCADE;
CREATE TABLE log (
  id smallint DEFAULT 'nextval('log_id_seq'::regclass)' NOT NULL,
  ts timestamp without time zone(6) DEFAULT now() NOT NULL,
  channel_id smallint NOT NULL,
  users_id smallint NOT NULL,
  type text NOT NULL,
  entry text NOT NULL,
  PRIMARY KEY (id)
);



--
-- Table: tag
--
DROP TABLE tag CASCADE;
CREATE TABLE tag (
  id smallint DEFAULT 'nextval('tag_id_seq'::regclass)' NOT NULL,
  name text,
  log_id smallint NOT NULL,
  PRIMARY KEY (id)
);



--
-- Table: user_
--
DROP TABLE user_ CASCADE;
CREATE TABLE user_ (
  user_id smallint DEFAULT 'nextval('user_user_id_seq'::regclass)' NOT NULL,
  email text,
  PRIMARY KEY (user_id)
);



--
-- Table: users
--
DROP TABLE users CASCADE;
CREATE TABLE users (
  id smallint DEFAULT 'nextval('users_id_seq'::regclass)' NOT NULL,
  email text,
  PRIMARY KEY (id)
);

--
-- Foreign Key Definitions
--

ALTER TABLE channel_report ADD FOREIGN KEY (channel_id)
  REFERENCES channel (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE channel_report ADD FOREIGN KEY (users_id)
  REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE log ADD FOREIGN KEY (channel_id)
  REFERENCES channel (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE log ADD FOREIGN KEY (users_id)
  REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE tag ADD FOREIGN KEY (log_id)
  REFERENCES log (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;
