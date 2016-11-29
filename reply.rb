require_relative 'questions_db'

class Reply
  attr_accessor :question_id, :user_id, :body, :parent_id

  def self.find_by_id(id)
    selection = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    Reply.new(selection.first)
  end

  def self.find_by_user_id(user_id)
    selection = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL

    selection.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    selection = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    selection.map { |datum| Reply.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
    @body = options['body']
    @parent_id = options['parent_id']
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id, @body, @parent_id)
        INSERT INTO
          replies(user_id, question_id, body, parent_id)
        VALUES
          (?, ?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id, @body, @parent_id, @id)
        UPDATE
          replies
        SET
          user_id = ?, question_id = ?, body = ?, parent_id = ?
        WHERE
          id = ?
      SQL
    end
    self
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_id)
  end

  def child_replies
    selection = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL

    selection.map { |datum| Reply.new(datum) }
  end
end
