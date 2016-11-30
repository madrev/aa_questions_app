require 'singleton'
require 'sqlite3'
require_relative 'model_base'
require_relative 'question'
require_relative 'reply'
require_relative 'user'
require_relative 'follow'
require_relative 'like'
require 'byebug'


class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end
