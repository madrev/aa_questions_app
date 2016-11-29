require 'singleton'
require 'sqlite3'
require_relative 'question'
require_relative 'reply'
require_relative 'user'
require_relative 'follow'
require_relative 'like'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

# class ModelBase
#
#   def self.find_by_id(table, id)
#     QuestionsDatabase.instance.execute(<<-SQL, table, id)
#       SELECT
#         *
#       FROM
#         #{table}
#       WHERE
#         id = ?
#     SQL
#   end
#
#   def self.all
#   end
# end
