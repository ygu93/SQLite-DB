require_relative 'questions_db'

class ModelBase
  def self.all
    table = TABLEIZE[self.to_s]
    data = QuestionsDatabase.instance.execute("SELECT * FROM #{table}")
    data.map { |datum| self.new(datum) }
  end

  def self.find_by_id(id)
    table = TABLEIZE[self.to_s]
    found = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table}
      WHERE
        id = ?
    SQL
    return nil unless found.length > 0

    self.new(found.first)
  end

  def save
    @id ? update : create
  end

  def update
    table = TABLEIZE[self.to_s]

    i_vars = self.instance_variables.select { |iv| iv != :@id }
    i_vars.map! { |iv| iv[1..-1] }

    columns = ""
    i_vars.each { |iv| columns << "#{iv} = #{self.send(iv)}" }
require 'byebug' ; debugger
    QuestionsDatabase.instance.execute(<<-SQL, @id)
      UPDATE
        #{table}
      SET
        #{columns}
      WHERE
        id = ?
    SQL
  end

  def create
    table = TABLEIZE[self.to_s]

    i_vars = self.instance_variables.select { |iv| iv != :@id }
    i_vars.map! { |iv| iv[1..-1] }

    columns = ""
    i_vars.each { |iv| columns << "#{iv}" }

    values = ""
    i_vars.each { |iv| values << "#{self.send(iv)}, "}
    values = values[0...-2]

    QuestionsDatabase.instance.execute(<<-SQL)
      INSERT INTO
        #{table}(#{columns})
      VALUES
        (#{values})
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  TABLEIZE = {
    'Reply' => 'replies' ,
    'User' => 'users' ,
    'Question' => 'questions',
    'QuestionLike' => 'question_likes',
    'QuestionFollow' => 'question_follows'
  }
end
