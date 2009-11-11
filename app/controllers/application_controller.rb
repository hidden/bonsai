# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '508416363d2bbc1e88e700958a8ce24f'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  before_filter :set_user

  def set_user
    if session[:user_id].nil? and not cookies[:token].nil?
     user_from_token = User.find_by_token(cookies[:token])
     session[:user_id] = user_from_token.id unless user_from_token.nil?
    end
    @current_user = session[:user_id].nil? ? AnonymousUser.new : User.find(session[:user_id])
  end

  before_filter :set_locale
    def set_locale
      logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
      if(extract_locale_from_accept_language_header == "sk" || extract_locale_from_accept_language_header == "en")
          I18n.locale = extract_locale_from_accept_language_header
      else
        I18n.locale = :en
      end
      logger.debug "* Locale set to '#{I18n.locale}'"
    end
  private
    def extract_locale_from_accept_language_header
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first unless request.env['HTTP_ACCEPT_LANGUAGE'].nil?
    end 
end
