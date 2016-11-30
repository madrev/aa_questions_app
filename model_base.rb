class ModelBase

  TABLE_NAMES = {
    'Question' => 'questions',
    'User' => 'users',
    'QuestionFollow' => 'question_follows',
    'QuestionLike' => 'question_likes',
    'Reply' => 'replies'
  }.freeze

  def self.find_by_id(id)
    selection = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{TABLE_NAMES[self.to_s]}
      WHERE
        id = ?
    SQL

    self.new(selection.first)
  end

  def self.all
    selection = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{TABLE_NAMES[self.to_s]}
    SQL
    selection.map { |datum| self.new(datum) }
  end

  def save
    @id.nil? ? create : update
    self
  end

  def create
    QuestionsDatabase.instance.execute(<<-SQL, instance_values_array.drop(1))
      INSERT INTO
        #{insert_into_string}
      VALUES
        #{insert_values_string}
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    QuestionsDatabase.instance.execute(<<-SQL, instance_values_array.rotate)
      UPDATE
        #{TABLE_NAMES[self.class.to_s]}
      SET
        #{update_set_string}
      WHERE
        id = ?
    SQL
  end

  def self.where(options)
    selection = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{TABLE_NAMES[self.to_s]}
      WHERE
        #{self.get_where_string(options)}
    SQL

    selection.map {|datum| self.new(datum)}
  end

  def self.method_missing(method_name, *args)
    method_name = method_name.to_s

    if method_name.start_with?("find_by_")
      text = method_name[("find_by_".length)..-1]
      column_names = text.split("_and_")

      options = Hash.new

      column_names.length.times do |i|
        options[column_names[i]] = args[i]
      end

      self.where(options)

    else
      super
    end
  end




  private

  def self.get_where_string(options)
    return options if options.is_a?(String)
    result = []
    options.each do |k,v|
      result << (v.is_a?(String) ? "#{k} = '#{v}'" : "#{k} = #{v}")
    end
    result.join(" AND ")
  end

  def instance_values_array
    self.instance_variables.map { |var| self.instance_variable_get(var) }
  end

  def insert_into_string
    columns = self.instance_variables.map { |col| col.to_s[1..-1] }
    "#{TABLE_NAMES[self.class.to_s]} (#{columns.drop(1).join(', ')})"
  end

  def insert_values_string
    num = self.instance_variables.count - 1
    "(#{(Array.new(num) { '?' }).join(', ')})"
  end

  def update_set_string
    columns = self.instance_variables.map { |col| col.to_s[1..-1] }
    "#{columns.drop(1).join(' = ?, ')} = ?"
  end
end
