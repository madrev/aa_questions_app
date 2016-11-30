#require_relative 'questions_db'

class QuestionFollow < ModelBase
  attr_accessor :question_id, :user_id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.followers_for_question_id(question_id)
    selection = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows ON question_follows.user_id = users.id
      WHERE
        question_follows.question_id = ?;
    SQL
    selection.map { |datum| User.new(datum) }

  end

  def self.followed_questions_for_user_id(user_id)
    selection = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows ON question_follows.question_id = questions.id
      WHERE
        question_follows.user_id = ?;
    SQL
    selection.map { |datum| Question.new(datum) }

  end

  def self.most_followed_questions(n)
    selection = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*, COUNT(*)
      FROM
        questions
      JOIN
        question_follows ON question_follows.question_id = questions.id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT
       ?
    SQL
    selection.map { |datum| Question.new(datum) }
  end

end
