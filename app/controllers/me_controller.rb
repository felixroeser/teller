class MeController < ApplicationController
  before_filter :authenticate_user!
  
  def index
  end

  def vcard
  	# render text: current_user.vcard, content_type: :vcard
  	send_data current_user.vcard, filename: "album.vcf", content_type: :vcard
  end

end