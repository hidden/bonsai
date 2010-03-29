class UsersController < ApplicationController

    ssl_allowed :login

  def login
    session[:return_to] = request.referer if params[:commit]
    if APP_CONFIG['authentication_method'] == 'openid' then
      open_id_authentication
    else
      ldap_authentification
    end
  end

  def logout
    flash[:notice] = t(:logout)
    cookies.delete :token
    session[:user_id] = nil
    redirect_to Page.root.get_path unless Page.root.nil?
    redirect_to "/" if Page.root.nil?
  end

  def save_locale
    I18n.locale = params[:locale]
    @current_user.prefered_locale = params[:locale]
    @current_user.save if @current_user.respond_to? :save
    flash[:notice] = translate(:set_language)
    session[:toggle_text] = nil
    redirect_to :back
  end

  private

  def ldap_authentification
    return unless params[:username]
      #authenticator = Rails.env.production? ? SimpleLDAP : SimpleLDAP::Stub
      authenticator =  APP_CONFIG['authentication_method'] == 'ldap-stub' ? SimpleLDAP::Stub : SimpleLDAP 
     data = authenticator.authenticate(params[:username], params[:password], APP_CONFIG['ldap']['host'], APP_CONFIG['ldap']['port'], APP_CONFIG['ldap']['base_dn'])
    if data.nil?
        failed_login
      else
        user = User.find_or_create_by_username(:username => params[:username], :name => data['cn'].first)
        user.name=data['cn'].first
        user.save
        successful_login(user)
      end
  end

  def make_url(identity_url)
    identity_url = (identity_url.slice(0, 7) == "http://") ? identity_url : ("http://" + identity_url)
    identity_url += (identity_url.slice(-1, 1) == "/") ? "" : "/"
    return  identity_url
  end

  def validate_url(url)
    reg = /^(http\:\/\/)([\w_-]{2,}\.)+([\w_-]{2,})$/
    return (reg.match(url))? true : false
  end

  def open_id_authentication
    identity_url = params[:openid_identifier]

    if Rails.env.test?
        if !validate_url(identity_url)
          failed_login
        else
          name = "openid"
          user = User.find_or_create_by_username(:username => identity_url, :name => name)
          successful_login(user)
        end
    else
        authenticate_with_open_id(identity_url, :optinal => [ :nickname ] ) do |result, identity_url, profile|
        if result.successful?
          name = profile['nickname'] || "openid"
          user = User.find_or_create_by_username(:username => make_url(identity_url), :name => name)
          user.name = name
          user.save
          successful_login(user)
        else
          failed_login
        end
      end
    end
  end

  def successful_login(user)
    session[:user_id] = user.id
    cookies[:token] = {:value => user.token, :expires => 1.month.from_now}
    flash[:notice] = t(:login_successful)
    redirect_to session[:return_to]
  end

  def failed_login
    flash[:error] = t(:login_error)
    redirect_to session[:return_to]
  end
  
end

