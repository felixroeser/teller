class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :skip_trackable
  before_filter :set_locale

  # See https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  after_filter :store_location

  helper_method :mobile_device?, :ios_device?

  protected

  def store_location
   # store last url - this is needed for post-login redirect to whatever the user last visited.
      if (request.fullpath != "/users/sign_in" && \
          request.fullpath != "/users/sign_up" && \
          request.fullpath != "/users/password" && \
          !request.xhr?) # don't store ajax calls
        session[:previous_url] = request.fullpath 
      end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def skip_trackable
    request.env['devise.skip_trackable'] = true
  end

  def set_locale
    l = params[:locale] || session[:locale] || current_user.try(&:locale) || http_accept_language.compatible_language_from(['de', 'en'])

    if l && Teller::GLOBALS[:locales].keys.include?(l.to_s)
      I18n.locale = l
      session[:locale] = l
    end
  end

  # http://stackoverflow.com/questions/16715424/rails-4-devise-3-0-0-adding-username
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) do |u| 
      u.permit(:email)
    end
    devise_parameter_sanitizer.for(:sign_up) do |u| 
      u.permit(:name, :email, :locale, :password, :password_confirmation)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:name, :email, :password, :password_confirmation, :locale, :pseudo, :reviewed)
    end
  end

  # See https://gist.github.com/dalethedeveloper/1503252
  def mobile_device?
    true && request.user_agent =~ /Mobile|webOS/
  end

  def ios_device?
    true && request.user_agent =~ /(Mobile\/.+Safari)|(AppleWebKit\/.+Mobile)/ && (request.user_agent =~ /.+Android/i).nil?
  end

  def ensure_admin
    raise ActionController::RoutingError.new('Not Found') unless current_user && current_user.admin?
  end

end
