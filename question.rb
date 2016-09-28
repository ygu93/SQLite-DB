require_relative 'model_base'

class Question < ModelBase
  attr_accessor :title, :body, :user_id

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

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
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

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  # def save
  #   @id ? update : create
  # end
  #
  # def update
  #   QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id, @id)
  #     UPDATE
  #       questions
  #     SET
  #       title = ?, body = ?, user_id = ?
  #     WHERE
  #       id = ?
  #   SQL
  # end
  #
  # def create
  #   QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
  #     INSERT INTO
  #       questions(title, body, user_id)
  #     VALUES
  #       (?, ?, ?)
  #   SQL
  #
  #   @id = QuestionsDatabase.instance.last_insert_row_id
  # end
end
