class PostingsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_posting, except: [:index]
  before_action :check_permissions, except: [:index]

  # GET /postings
  def index
    @blank_postings = current_user.postings.blank.latest_first.includes(:media)
    @postings = current_user.all_postings.
      published.
      latest_first.
      includes(:media, :album, :user).
      page(params[:page])
  end

  # GET /postings/1
  def show
  end

  # GET /postings/1/edit
  def edit
  end

  # PATCH/PUT /postings/1
  def update
    if @posting.update(posting_params)

      if @posting.publish_in.present? and @posting.state != 'scheduled' and @posting.album.present?
        @posting.update(state: 'scheduled')
        PublishPosting.perform_async(posting_id: @posting.id)
        flash[:notice] = 'Your posting will be published soon!'
      end

      redirect_to @posting, notice: 'Posting was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /postings/1
  def destroy
    @posting.destroy
    redirect_to postings_url, notice: 'Posting was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_posting
      @posting = Posting.where(id: params[:id]).first
    end

    # Only allow a trusted parameter "white list" through.
    def posting_params
      return nil if params[:posting][:album_id] && !AlbumOwnership.where(album_id: params[:posting][:album_id], user_id: current_user.id).exists?

      params.require(:posting).permit(:title, :body, :album_id, :publish_in, :recorded_at)
    end

    def check_permissions
      redirect_to(postings_path) unless @posting && (current_user.id == @posting.user_id || (@posting.album_id.present? && @posting.album.editable_by(current_user)))
    end
end
