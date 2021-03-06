# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include PathsHelper # include paths as controller methods
  include SslRequirement # include for https authentification
  filter_parameter_logging :password

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '508416363d2bbc1e88e700958a8ce24f'

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  def ssl_required?
    (APP_CONFIG['use_https'] and !session[:user_id].nil?)
  end

  before_filter :set_user
  before_filter :set_locale
  if (APP_CONFIG['authentication_method'] == 'facebook')
    before_filter :set_facebook_session
    before_filter :fetch_logged_in_user
    helper_method :facebook_session
  end

  def set_user
    if session[:user_id].nil? and not cookies[:token].nil?
      user_from_token = User.find_by_token(cookies[:token])
      session[:user_id] = user_from_token.id unless user_from_token.nil?
    end
    @current_user = User.find_by_id(session[:user_id]) unless session[:user_id].nil?
    @current_user = AnonymousUser.new(session) if @current_user.nil?
  end

  def set_locale
    locale = @current_user.prefered_locale.nil? ? get_locale_from_header : @current_user.prefered_locale
    locale = :en if locale.nil?
    I18n.locale = I18n.available_locales.include?(locale.to_sym) ? locale : :en
  end

  def not_logged_in
    redirect_to root_path unless (@current_user.class == AnonymousUser)
  end

  def fetch_logged_in_user
    if facebook_session
      @current_user = User.find_by_fb_id(facebook_session.user.uid.to_i)
    else
      return unless session[:user_id]
      @current_user = User.find_by_id(session[:user_id])
    end
  end

  def redirect_back_or_default(where=nil)
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to where.nil? ? root_path : where
  end

  private
  def get_locale_from_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first unless request.env['HTTP_ACCEPT_LANGUAGE'].nil?
  end
end
