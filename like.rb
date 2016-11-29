require_relative 'questions_db'

class QuestionLike
  attr_accessor :question_id, :user_id

  def self.find_by_id(id)
    selection = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL

    QuestionLike.new(selection.first)
  end

  def self.likers_for_question_id(question_id)
    selection = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_likes ON question_likes.user_id = users.id
      WHERE
        question_likes.question_id = ?
    SQL

    selection.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    selection = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        question_likes
      WHERE
        question_id = ?
    SQL

    selection.values.first
  end

  def self.liked_questions_for_user_id(user_id)
    selection = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes ON question_likes.question_id = questions.id
      WHERE
        question_likes.user_id = ?
    SQL

    selection.map { |datum| Question.new(datum) }
  end

  def self.most_liked_questions(n)
    selection = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
       questions.*, COUNT(*)
      FROM
       questions
      JOIN
        question_likes ON question_likes.question_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL
    selection.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

end
