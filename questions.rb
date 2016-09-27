require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation  = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :fname, :lname

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless user.length > 0

    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil unless user.length > 0

    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end
end

class Question
  attr_accessor :title, :body, :user_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil unless question.length > 0

    Question.new(question.first)
  end

  def self.find_by_author_id(author_id)
    user = User.find_by_id(author_id)
    raise "#{author_id} not found in DB" unless user

    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    return nil unless questions.length > 0

    questions.map{ |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def author
    User.find_by_id(@user_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end
end

class QuestionFollow
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end

class Reply
  attr_accessor :body, :question_id, :reply_id, :user_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil unless reply.length > 0

    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    user = User.find_by_id(user_id)
    raise "#{user_id} not found in DB" unless user

    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil unless replies.length > 0

    replies.map{ |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    question = Question.find_by_id(question_id)
    raise "#{question_id} not found in DB" unless question

    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil unless replies.length > 0

    replies.map{ |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @question_id = options['question_id']
    @reply_id = options['reply_id']
    @user_id = options['user_id']
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_id(@reply_id)
  end

  def child_replies
    replies = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        reply_id = ?
    SQL
    return nil unless replies.length > 0

    replies.map { |reply| Reply.new(reply) }
  end
end

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

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
