DROP TABLE channel_report;
DROP TABLE tag;
DROP TABLE log;
DROP TABLE channel;
DROP TABLE users;


CREATE TABLE channel (
  id          SERIAL NOT NULL PRIMARY KEY,
  name        TEXT NOT NULL,
  description TEXT
);


CREATE TABLE users (
  id    SERIAL NOT NULL PRIMARY KEY,
  email      TEXT
);

CREATE TABLE log (
  id      SERIAL NOT NULL PRIMARY KEY,
  ts          TIMESTAMP NOT NULL DEFAULT NOW(),
  channel_id  INT NOT NULL REFERENCES channel(id),
  users_id     INT NOT NULL REFERENCES users(id),
  type        TEXT NOT NULL,
  entry       TEXT NOT NULL
);

CREATE TABLE tag (
  id SERIAL NOT NULL PRIMARY KEY,
  name   TEXT,
  log_id INT NOT NULL REFERENCES log(id)
);


CREATE TABLE channel_report (
  users_id  INT NOT NULL REFERENCES users(id),
  channel_id INT NOT NULL REFERENCES channel(id),
  report_expires TIMESTAMP,
  report_frequency   TEXT,
  report_last TIMESTAMP,
  PRIMARY KEY (users_id, channel_id)
);

