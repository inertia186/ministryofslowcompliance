class CommentsController < ::ApplicationController
  before_filter :load_commentable, except: [:edit, :show, :update, :destroy]
  
  def index
    @comments = @commentable.comments.latest.paginate(page: params[:page], per_page: 25)
  end
  
  def new
    @comment = @commentable.comments.new(author: current_user)
  end

  def edit
    @comment = current_user.comments.find(params[:id])
    @commentable = @comment.commentable
  end
  
  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.author = current_user

    if @comment.save
      redirect_to @commentable.original_post, notice: "Reply saved."
    else
      render :new
    end
  end

  def update
    
    @comment = current_user.comments.find(params[:id])
    @commentable = @comment.commentable
    
    if @comment.update_attributes(comment_params)
      flash[:success] = "Comment updated."
      redirect_to @commentable.original_post
    else
      flash.now[:error] = "Please fix any errors below."
      render :edit
    end
  end

  def destroy
    if current_user.nil?
      redirect_to root_url
      flash[:error] = "You cannot delete this comment."
    end
    @comment = current_user.comments.find(params[:id])
    @commentable = @comment.commentable
    if @comment
      if @comment.cached_flat_related_comments.count == 0
        @comment.destroy
      else
        @comment.redact!
      end
      flash[:notice] = "Post has been removed."
    else
      flash[:error] = "You cannot delete this comment."
    end
    redirect_to @commentable.original_post
  end
  
private
  # def load_commentable
  #   resource, id = request.path.split('/')[1, 2]
  #   @commentable = resource.singularize.classify.constantize.find(id)
  # end
  
  def load_commentable
    klass = [Post, Comment].detect { |c| params["#{c.name.underscore}_id"]}
    @commentable = klass.find(params["#{klass.name.underscore}_id"])
  end
  
  def comment_params
    params.require(:comment).permit(:body)
  end  
end
