class PostsController < ::ApplicationController
  before_filter except: [:show] do
    redirect_to welcome_url unless user_signed_in?
  end
  
  def index
    @posts ||= current_user.posts.latest
    
    @posts = @posts.paginate(page: params[:page], per_page: 25)
    
    render :index
  end
  
  def search
    @posts = current_user.posts.latest
    @search_text = params[:search_text]

    unless @search_text.empty?
      @posts = @posts.where('posts.title LIKE ? OR posts.body LIKE ?', @search_text, @search_text)
    end

    index
  end
  
  def new
    @post = current_user.posts.new
  end

  def show
    @post = Post.where(id: params[:id]).first
  end
  
  def edit
    @post = current_user.posts.find(params[:id])
  end
  
  def create
    @post = current_user.posts.new(post_params)
    @post.author = current_user
    
    if @post.save
      flash[:success] = "Post saved."
      redirect_to posts_url
    else
      flash.now[:error] = "Please fix any errors below."
      render :new
    end
  end

  def update
    
    @post = current_user.posts.find(params[:id])
    
    if @post.update_attributes(post_params)
      flash[:success] = "Post updated."
      redirect_to posts_url
    else
      flash.now[:error] = "Please fix any errors below."
      render :edit
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id]) unless current_user.nil?
    if @post
      if @post.comments.count == 0
        @post.destroy
      else
        @post.redact!
      end
      flash[:notice] = "Post has been removed."
    else
      flash[:error] = "You cannot delete this post."
    end
    redirect_to posts_url
  end

private
  def post_params
    params.require(:post).permit(:author_id, :title, :body)
  end
end