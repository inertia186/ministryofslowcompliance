class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :confirmable, :registerable, :validatable
  has_many :posts, :foreign_key => 'author_id', dependent: :nullify
  has_many :comments, :foreign_key => 'author_id', dependent: :nullify

  scope :top_five_authors, select('users.*, ( SELECT COUNT(posts.id) FROM posts WHERE posts.author_id = users.id ) AS posts_count').
    joins(:posts). # This inner join filters out posts_count < 1 since SQLite3 refuses to filter on a pseudo-column.
    order('posts_count DESC').uniq.limit(5)

  validates :nickname, :presence => true, :uniqueness => { :case_insensitive => true } 
  validates :email, :presence => true, :email_address => true, :uniqueness => { :case_insensitive => true }

  after_commit do |user|
    Rails.cache.delete(['Post', 'author', user.id])
    Rails.cache.delete(['Comment', 'author', user.id])
  end

  def self.cached_top_five_authors
    Rails.cache.fetch(['User', 'top_five_authors']) do
      top_five_authors.to_a
    end
  end

  def to_param
    if nickname
      "#{id}-#{nickname.parameterize}"
    else
      id.to_s
    end
  end
end
