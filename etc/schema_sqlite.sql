-- for sqlite

DROP TABLE token;
DROP TABLE tag;
DROP TABLE log;
DROP TABLE channel;
DROP TABLE user;
DROP TABLE irc_user;

CREATE TABLE channel (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE user (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  email      TEXT UNIQUE,
  username   TEXT UNIQUE,
  password   TEXT
);

CREATE TABLE irc_user (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  irc_user   TEXT NOT NULL,
  ts         TIMESTAMP NOT NULL,
  user_id    INTEGER REFERENCES user(id)
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
  data    TEXT NOT NULL
);
