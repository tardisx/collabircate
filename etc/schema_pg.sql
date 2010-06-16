-- for sqlite

DROP TABLE token;
DROP TABLE tag;
DROP TABLE log;
DROP TABLE file;
DROP TABLE channel;
DROP TABLE irc_nick;
DROP TABLE irc_user;
DROP TABLE "user";

CREATE TABLE channel (
  id          SERIAL PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE "user" (
  id         SERIAL PRIMARY KEY,
  email      TEXT UNIQUE,
  username   TEXT UNIQUE,
  password   TEXT
);

CREATE TABLE irc_user (
  id         SERIAL PRIMARY KEY,
  irc_user   TEXT NOT NULL,
  ts         TIMESTAMP NOT NULL,
  user_id    INTEGER REFERENCES "user"(id)
);

CREATE TABLE irc_nick (
  id          SERIAL PRIMARY KEY,
  nick        TEXT NOT NULL,
  irc_user_id INTEGER NOT NULL REFERENCES irc_user(id),
  ts          TIMESTAMP NOT NULL
);

CREATE TABLE log (
  id          SERIAL PRIMARY KEY,
  ts          TIMESTAMP NOT NULL,
  channel_id  INT NOT NULL REFERENCES channel(id),
  irc_user_id INT NOT NULL REFERENCES irc_user(id),
  type        TEXT NOT NULL,
  entry       TEXT NOT NULL
);

CREATE TABLE tag (
  id     SERIAL PRIMARY KEY,
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
  id          SERIAL PRIMARY KEY,
  ts          TIMESTAMP NOT NULL,
  channel_id  INT NOT NULL REFERENCES channel(id),
  irc_user_id INTEGER NOT NULL REFERENCES irc_user(id),
  filename  TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  size      INT NOT NULL
);
