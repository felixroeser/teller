# FIXME use ajax!
class Albums::Postings::CommentsController < ApplicationController
  before_action :set_album
  before_action :set_posting  

  before_filter :authenticate_user!
  before_action :check_permissions

  def new
    @comment = Comment.new(public: false)
  end

  def create
    @comment = Comment.new(comment_params.merge({user_id: current_user.id, posting_id: @posting.id}))

    if @comment.save
      redirect_to album_postings_path(@album), notice: t('comments.created.saved', email: @album.users.map(&:email))
    else
      render action: 'new'
    end    
  end

  private

  def set_album
    @album = Album.find(params[:album_id])
  end

  def set_posting
    @posting = @album.postings.find(params[:posting_id])
  end

  def check_permissions
    redirect_to '/' unless @album.readable_by(current_user)
  end

  # Only allow a trusted parameter "white list" through.
  def comment_params
  params.require(:comment).permit(:message, :public)
  end

end
