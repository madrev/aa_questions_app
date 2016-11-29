DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);


DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);


DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  parent_id INTEGER,
  body TEXT NOT NULL,


  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);


DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO
  users(fname, lname)
VALUES
  ('Maddie', 'Revill'),
  ('Hope', 'Wanroy'),
  ('Alex', 'Sherman');


INSERT INTO
  questions(title, body, user_id)
VALUES
  ('What is the best way to start a conversation with a stranger?',
  'I need help talking to ppl plz', (SELECT id FROM users WHERE fname = 'Maddie')),
  ('Everyone on Earth gets to wish for a superpower but you''ll only get yours if literally no one else wishes for the same power. What do you wish for?',
  'Being the 4th best looking person in the world', (SELECT id FROM users WHERE fname = 'Hope'));

INSERT INTO
  question_follows(question_id, user_id)
VALUES
  (1, 2),
  (1, 3),
  (2, 3);

INSERT INTO
  replies(question_id, user_id, parent_id, body)
VALUES
  (1, 2, NULL, 'crosswords.'),
  (1, 3, 1, 'yep'),
  (2, 3, NULL, 'Get $29410881191.36 in my bank account every time I lick the spare tyre of my car, on a March Sunday Morning');

INSERT INTO
  question_likes(question_id, user_id)
VALUES
  (1, 3),
  (2, 1),
  (2, 3);
