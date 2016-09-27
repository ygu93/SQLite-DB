require_relative 'questions_db'

class QuestionFollow
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN question_follows
        ON users.id = question_follows.user_id
      JOIN questions
        ON questions.id = question_follows.question_id
      WHERE
        questions.id = ?
    SQL
    return nil unless users.length > 0

    users.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN question_follows
        ON questions.id = question_follows.question_id
      JOIN users
        ON users.id = question_follows.user_id
      WHERE
        users.id = ?
    SQL
    return nil unless questions.length > 0

    questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN question_follows
        ON questions.id = question_follows.question_id
      GROUP BY
        questions.user_id
      ORDER BY
        COUNT(questions.user_id) DESC
      LIMIT
        ?
    SQL
    return nil unless questions.length > 0

    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
