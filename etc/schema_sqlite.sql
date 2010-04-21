-- for sqlite

DROP TABLE tag;
DROP TABLE log;
DROP TABLE channel;
DROP TABLE user;

CREATE TABLE channel (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE user (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  email      TEXT UNIQUE
);

CREATE TABLE log (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  ts          TIMESTAMP NOT NULL,
  channel_id  INT NOT NULL REFERENCES channel(id),
  user_id    INT NOT NULL REFERENCES user(id),
  type        TEXT NOT NULL,
  entry       TEXT NOT NULL
);

CREATE TABLE tag (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  name   TEXT,
  log_id INT NOT NULL REFERENCES log(id)
);

