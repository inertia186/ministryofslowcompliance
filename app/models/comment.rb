class Comment < ActiveRecord::Base
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :commentable, :polymorphic => true, touch: :latest_reply_at
  has_many :comments, as: :commentable, dependent: :destroy
  
  scope :latest, order('comments.created_at DESC')
  scope :directly_to_post, where(commentable_type: 'Post')
  scope :not_directly_to_post, where(commentable_type: 'Comment')
  scope :without_authors, where('comments.author_id IS NULL')

  validates :commentable, :presence => true
  validates :author, :presence => true
  validates :body, :presence => true, :length => { :maximum => 640 }, :allow_nil => true, :allow_blank => true
  
  after_create do |comment|
    op = comment.original_post
    op.total_replies_count = op.total_replies_count + 1
    op.save
  end

  after_destroy do |comment|
    op = comment.original_post
    op.total_replies_count = op.total_replies_count - 1
    op.save
  end
  
  before_save if: :body_changed? do |comment|
    comment.body_updated_at = Time.now
  end
  
  after_commit do |comment|
    Rails.cache.delete([comment.class.name, 'flat_related_comments', comment.id])
    Rails.cache.delete([comment.original_post.class.name, 'flat_related_comments', comment.original_post.id])
    Rails.cache.delete([self.class.name, 'author', comment.author_id])
  end
  
  validate do |comment|
    if comment.commentable == comment
      errors.add(:commentable, "cannot be its own child")
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
    Rails.cache.fetch([self.class.name, 'flat_related_comments', self.id]) do
      flat_related_comments.to_a
    end
  end
  
  def root_comment
    if self.commentable_type == 'Post'
      self
    else
      @root_comment ||= commentable.root_comment unless commentable.nil?
    end
  end
  
  def original_post
    @original_post ||= root_comment.commentable
  end
  
  def redact!
    self.author = nil
    self.body = self.body.gsub(/[\S]/, '&#x2588;')
    self.save(validate: false)
  end
end
