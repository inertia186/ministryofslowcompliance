class Post < ActiveRecord::Base
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  has_many :comments, as: :commentable, dependent: :destroy
  
  scope :latest, order('posts.created_at DESC')
  scope :within_days, lambda {|days = 7| where(['posts.created_at > ?', days.days.ago]) }
  scope :within_hours, lambda {|hours = 6| where(['posts.created_at > ?', hours.hours.ago]) }
  scope :without_authors, where('posts.author_id IS NULL')
  
  validates :author, :presence => true
  validates :title, :presence => true, :length => { :maximum => 60 }
  validates :body, :presence => true, :length => { :maximum => 640 }, :allow_nil => true, :allow_blank => true
  validates :url, :format => { :with => /\b(([\w-]+:\/\/?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|\/)))/ }, :allow_nil => true, :allow_blank => true
  validate :valid_body_or_url
  validate :valid_title_and_body

  before_save if: :body_changed? do |post|
    post.body_updated_at = Time.now
  end
  
  after_commit do |post|
    Rails.cache.delete([post.class.name, 'flat_related_comments', post.id])
    Rails.cache.delete([post.author.class.name, 'top_five_authors'])
    Rails.cache.delete([post.class.name, 'author', post.author_id])    
  end
  
  def to_param
    if title
      "#{id}-#{title.parameterize}"
    else
      id.to_s
    end
  end
  
  def word_count
    body.scan(/\w+/).size if body
  end

  def cached_author
    User # Pre-load the class for Marshal.
    Rails.cache.fetch([self.class.name, 'author', self.author_id]) do
      author
    end
  end

  def related_comments
    self.comments.includes(comments: {
      comments: {
        comments: {
          comments: {
            comments: {
              comments: :comments
            }
          }
        }
      } 
    })
  end

  # Use with caution
  def flat_related_comments
    comments = self.comments
    ids = comments.pluck('comments.id')
    comments.each do |comment|
      related_comments = comment.flat_related_comments
      ids = ids + related_comments.pluck('comments.id') unless related_comments.empty?
    end
    
    if ids.empty?
      [] # FIXME in Rails 4
    else
      Comment.where(id: ids.uniq)
    end
  end
  
  def cached_flat_related_comments
    Comment # Pre-load the class for Marshal.
    Rails.cache.fetch([self.class.name, 'flat_related_comments', self.id]) do
      flat_related_comments.to_a
    end
  end
  
  def original_post
    self
  end
  
  def redact!
    self.author = nil
    self.title = "[REDACTED]"
    self.body = self.body.gsub(/[\S]/, '&#x2588;')
    self.save(validate: false)
  end
private
  def valid_body_or_url
    if body.present? && url.present?
      errors[:body] << "must not have url if body present"
    end
  end
  def valid_title_and_body
    unless Post.where(title: title).where(body: body).count == 0
      errors[:title] << "and exact content already posted"
    end
  end
end
