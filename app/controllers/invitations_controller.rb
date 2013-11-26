class InvitationsController < ApplicationController
  before_filter :authenticate_user!, except: [:accept, :rejected]
  before_action :set_invitation, only: [:show, :destroy]
  before_action :set_invitation_from_token, only: [:accept, :accepted, :rejected]
  before_action :can_create_invitation, except: [:accept, :accepted, :rejected]

  # GET /invitations
  def index
    @invitations = Invitation.where(state: 'open', user_id: current_user.id).includes(:recipient).all
  end

  # GET /invitations/new
  def new
    @invitation = Invitation.new
  end

  # POST /invitations
  def create
    p = invitation_params

    @recipient_emails = p[:recipient_email].
      split(/;|,|\s/).
      select { |s| s =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}

    @albums = current_user.albums.where(id: p[:album_ids].select { |s| s.present? } )

    if @recipient_emails.present? && @albums.present?
      CreateInvitations.perform_async({
        user_id: current_user.id,
        album_ids: @albums.map(&:id),
        recipient_emails: @recipient_emails,
        message: p[:message],
        locale: p[:locale]
      })
    else
      @invitation = Invitation.new(invitation_params)
      @invitation.valid?
      render action: 'new'    
    end
  end

  # DELETE /invitations/1
  def destroy
    msg = if @invitation.user == current_user
      @invitation.destroy
      'Invitation was successfully destroyed.'
    else
      'You are not allowed to do this!'
    end

    redirect_to invitations_url, notice: msg
  end

  def accept
  end

  def accepted
    UpdateInvitation.perform_async(id: @invitation.id, action: 'accept', acting_user_id: current_user.id)

    sleep 1

    flash[:notice] = "You accepted the invitation to join #{@invitation.albums.map(&:title).join(', ')}"
    redirect_to me_path
  end

  def rejected
    UpdateInvitation.perform_async({
      id: @invitation.id, 
      action: 'reject', 
      acting_user_id: current_user ? current_user.id : nil
    })

    flash[:notice] = t('invitations.rejected.notic')
    redirect_to current_user ? :invitations_path : root_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invitation
      @invitation = Invitation.find(params[:id])
    end

    def set_invitation_from_token
      @invitation = Invitation.state_open.where(token: params[:id]).first
      return if @invitation.present?

      flash[:notice] = t('invitations.taken')
      target = current_user && (current_user.has_albums? || current_user.can_create_album?) ? invitations_path : '/'
      redirect_to target
    end

    # Only allow a trusted parameter "white list" through.
    def invitation_params
      params.require(:invitation).permit(:message, {album_ids: []}, :recipient_email, :locale)
    end

    def can_create_invitation
      return if current_user.has_albums? || current_user.can_create_album?

      redirect_to invitations_path, notice: 'You cant create invitations for albums!'
    end

end
