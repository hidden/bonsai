# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include PathsHelper # include paths as controller methods
  filter_parameter_logging :password

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
      session[:ignore].nil? ? @ignore_header = false : @ignore_header = session[:ignore]
      if @current_user.nil? || @current_user.instance_of?(AnonymousUser) #anonymous user, locale from session or browser settings
        if !session[:locale].nil?
          I18n.locale = session[:locale]
        else
          set_locale_from_header
        end
      else  #logged user, locale from DB or browser settings
        if @current_user.prefered_locale.nil?
           set_locale_from_header
        else
          I18n.locale = @current_user.prefered_locale
       end
      end
     end
  private
    def set_locale_from_header
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first unless request.env['HTTP_ACCEPT_LANGUAGE'].nil?
    end 
end
