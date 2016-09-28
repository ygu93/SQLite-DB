require_relative 'questions_db'

class ModelBase
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM #{TABLEIZE[self.to_s]}")
    data.map { |datum| self.new(datum) }
  end

  def self.find_by_id(id)
    found = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{TABLEIZE[self.to_s]}
      WHERE
        id = ?
    SQL
    return nil unless found.length > 0

    self.new(found.first)
  end

  TABLEIZE = {
    'Reply' => 'replies' ,
    'User' => 'users' ,
    'Question' => 'questions',
    'QuestionLike' => 'question_likes',
    'QuestionFollow' => 'question_follows'
  }
end
