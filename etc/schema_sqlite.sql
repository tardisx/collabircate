-- for sqlite

DROP TABLE token;
DROP TABLE tag;
DROP TABLE log;
DROP TABLE channel;
DROP TABLE user;
DROP TABLE file;
DROP TABLE irc_user;
DROP TABLE irc_nick;

CREATE TABLE channel (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE user (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  email      TEXT UNIQUE,
  username   TEXT UNIQUE,
  password   TEXT,
  admin      BOOLEAN NOT NULL DEFAULT 0
);

CREATE TABLE irc_user (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  irc_user   TEXT NOT NULL,
  ts         TIMESTAMP NOT NULL,
  user_id    INTEGER REFERENCES user(id)
);

CREATE TABLE irc_nick (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  nick        TEXT NOT NULL,
  irc_user_id INTEGER NOT NULL REFERENCES irc_user(id),
  ts          TIMESTAMP NOT NULL
);

CREATE TABLE log (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  ts          TIMESTAMP NOT NULL,
  channel_id  INT NOT NULL REFERENCES channel(id),
  irc_user_id INT NOT NULL REFERENCES irc_user(id),
  type        TEXT NOT NULL,
  entry       TEXT NOT NULL
);

CREATE TABLE tag (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  name   TEXT,
  log_id INT NOT NULL REFERENCES log(id)
);

CREATE TABLE token (
  token   TEXT PRIMARY KEY,
  expires TIMESTAMP NOT NULL,
  type    TEXT NOT NULL,
  data    TEXT NOT NULL
);

CREATE TABLE file (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  ts          TIMESTAMP NOT NULL,
  channel_id  INT NOT NULL REFERENCES channel(id),
  irc_user_id INTEGER NOT NULL REFERENCES irc_user(id),
  filename  TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  size      INT NOT NULL
);

-- Create a view that shows all log entries, be they regular or files.
CREATE VIEW log_combined
AS
  SELECT id,
         ts,
         'log' AS entry_type,
         channel_id,
         irc_user_id,
         TYPE,
         entry,
         NULL  AS filename,
         NULL  AS mime_type,
         NULL  AS size
  FROM   LOG
  UNION
  SELECT id,
         ts,
         'file' AS entry_type,
         channel_id,
         irc_user_id,
         NULL   AS TYPE,
         NULL   AS entry,
         filename,
         mime_type,
         size
  FROM   FILE
  ORDER  BY ts; 
