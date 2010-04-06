class UsersController < ApplicationController
  ssl_allowed :login
  before_filter :not_logged_in, :only => [:new, :create]
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = t(:registration_complete)
      redirect_to root_path
    else
      flash[:error]  = t(:registration_incomplete)
      render :action => 'new'
    end
  end

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
  def user_authenticated_by_password(username, password)
    user = User.find_by_username(username)
    (user and user.authenticated?(password))
  end


  def ldap_authentification
    return unless params[:username]
      authenticator =  APP_CONFIG['authentication_method'] == 'ldap-stub' ? SimpleLDAP::Stub : SimpleLDAP
      data = authenticator.authenticate(params[:username], params[:password], APP_CONFIG['ldap']['host'], APP_CONFIG['ldap']['port'], APP_CONFIG['ldap']['base_dn'])
    if data.nil? and !user_authenticated_by_password(params[:username], params[:password])
      failed_login
    else
      if control_user(params[:username])
        if data
          name = data['cn'].first
        else
          name = params[:username]
        end
        user = User.find_or_create_by_username(:username => params[:username], :name => name)
        user.password = params[:password]
        user.name = name
        #set_times(user)
        user.save
        successful_login(user)
      else
        banned_login(params[:username])
      end
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
        if control_user(identity_url)
          name = "openid"
          user = User.find_or_create_by_username(:username => identity_url, :name => name)
          #set_times(user)
          user.save
          successful_login(user)
        else
            banned_login(identity_url)
        end
        end
    else
        authenticate_with_open_id(identity_url, :optinal => [ :nickname ] ) do |result, identity_url, profile|
        if result.successful?
          if control_user(make_url(identity_url))
            name = profile['nickname'] || "openid"
            user = User.find_or_create_by_username(:username => make_url(identity_url), :name => name)
            user.name = name
            #set_times(user)
            user.save
            successful_login(user)
          else
            banned_login(make_url(identity_url))
          end
        else
          failed_login
        end
      end
    end
  end

  def control_user username
    user = User.find_by_username(username)
    if !user.nil? && !user.active?
      return false;
    end
    return true;
  end


  def banned_login user
    flash[:error] = t(:for_user) + user + t(:login_banned)
    redirect_to session[:return_to]
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

