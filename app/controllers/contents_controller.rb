class ContentsController < ::ApplicationController
  before_filter :capture_author_id, :only => [:index]
  before_filter :capture_top_authors

  def index
    @posts ||= Post.latest
    
    @posts = @posts.order('created_at DESC')

    @posts = @posts.where(author_id: @author) if @author

    @posts = @posts.paginate(page: params[:page], per_page: 25)
    
    render :index
  end
  
  def search_by_former_members
    @posts = Post.latest.where('author_id IS NULL')
    index
  end
  
  def welcome
    render layout: false
  end
  
private
  def capture_author_id
    author_id = params[:author_id]
    @author = User.find_by_id(author_id) if author_id
  end
  
  def capture_top_authors
    @top_authors = User.cached_top_five_authors
  end
end