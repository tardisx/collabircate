DROP TABLE channel_report;
DROP TABLE tag;
DROP TABLE log;
DROP TABLE channel;
DROP TABLE users;


CREATE TABLE channel (
  channel_id  SERIAL NOT NULL PRIMARY KEY,
  name        TEXT NOT NULL,
  description TEXT
);


CREATE TABLE users (
  user_id    SERIAL NOT NULL PRIMARY KEY,
  email      TEXT
);

CREATE TABLE log (
  log_id      SERIAL NOT NULL PRIMARY KEY,
  ts          TIMESTAMP NOT NULL DEFAULT NOW(),
  channel_id  INT NOT NULL REFERENCES channel(channel_id),
  user_id     INT NOT NULL REFERENCES users(user_id),
  type        TEXT NOT NULL,
  entry       TEXT NOT NULL
);

CREATE TABLE tag (
  tag_id SERIAL NOT NULL PRIMARY KEY,
  name   TEXT,
  log_id INT NOT NULL REFERENCES log(log_id)
);


CREATE TABLE channel_report (
  user_id  INT NOT NULL REFERENCES users(user_id),
  channel_id INT NOT NULL REFERENCES channel(channel_id),
  report_expires TIMESTAMP,
  report_frequency   TEXT,
  report_last TIMESTAMP,
  PRIMARY KEY (user_id, channel_id)
);

