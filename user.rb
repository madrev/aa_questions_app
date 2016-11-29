require_relative 'questions_db'

class User
  attr_accessor :fname, :lname

  def self.find_by_id(id)
    selection = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    User.new(selection.first)
  end

  def self.find_by_name(fname, lname)
    selection = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    User.new(selection.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
        INSERT INTO
          users(fname, lname)
        VALUES
          (?,?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
        UPDATE
          users
        SET
          fname = ?, lname = ?
        WHERE
          id = ?
      SQL
    end
    self
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    return 0.0 if authored_questions.empty?

    selection = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        (CAST(COUNT(question_likes.user_id) AS FLOAT) /
        COUNT(DISTINCT questions.id)) as average_likes
      FROM
        questions
      LEFT JOIN
        question_likes ON question_likes.question_id = questions.id
      WHERE
        questions.user_id = ?
      SQL
    selection.first.values.first
  end
end
