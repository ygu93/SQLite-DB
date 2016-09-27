require_relative 'questions_db'

class QuestionLike
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLike.new(datum) }
  end

  def self.find_by_id(id)
    question_like = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    return nil unless question_like.length > 0

    QuestionLike.new(question_like.first)
  end

  def self.likers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN question_likes
        ON users.id = question_likes.user_id
      JOIN questions
        ON questions.id = question_likes.question_id
      WHERE
        questions.id = ?
    SQL
    return nil unless users.length > 0

    users.map { |user| User.new(user) }
  end

  def self.num_likes_for_question_id(question_id)
    likes = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*)
      FROM
        questions
      JOIN question_likes
        ON questions.id = question_likes.question_id
      WHERE
        questions.id = ?
    SQL
    return nil unless likes.length > 0

    likes.first["COUNT(*)"]
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        users
      JOIN question_likes
        ON users.id = question_likes.user_id
      JOIN questions
        ON questions.id = question_likes.question_id
      WHERE
        users.id = ?
    SQL
    return nil if questions.empty?

    questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN question_likes
        ON questions.id = question_likes.question_id
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
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
