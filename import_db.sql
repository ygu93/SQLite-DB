DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(25) NOT NULL,
  lname VARCHAR(25) NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  reply_id INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES user(id)
);

DROP TABLE IF EXISTS question_likes ;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES user(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Bob', 'Smith'),
  ('Alice', 'Jones'),
  ('Teacher', 'McTeachyface');

INSERT INTO
  questions(title, body, user_id)
VALUES
  ('HELP!', 'computer won''t run', (SELECT id FROM users WHERE fname = 'Bob')),
  ('OH NO!', 'internet is broken', (SELECT id FROM users WHERE fname = 'Alice'));

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Bob'),
    (SELECT id FROM questions WHERE title = 'HELP!')),
  ((SELECT id FROM users WHERE fname = 'Alice'),
    (SELECT id FROM questions WHERE title = 'HELP!')),
  ((SELECT id FROM users WHERE fname = 'Alice'),
    (SELECT id FROM questions WHERE title = 'OH NO!'));

INSERT INTO
  replies(body, question_id, user_id)
VALUES
  ('try restarting',
    (SELECT id FROM questions WHERE title = 'HELP!'),
    (SELECT id FROM users WHERE fname = 'Teacher'));

INSERT INTO
  question_likes(user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Alice'),
   (SELECT id FROM questions WHERE title = 'HELP!'));
