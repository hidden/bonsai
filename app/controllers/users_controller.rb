class UsersController < ApplicationController
  def login
    if APP_CONFIG['authentication_method'] == 'openid' then
      open_id_authentication
    else
      return unless params[:username]
      authenticator = Rails.env.production? ? SimpleLDAP : SimpleLDAP::Stub
      data = authenticator.authenticate(params[:username], params[:password], 'ldap.stuba.sk', 389, 'ou=People,dc=stuba,dc=sk')
      if data.nil?
        failed_login
      else
        user = User.find_or_create_by_username(:username => params[:username], :name => data['cn'].first)
        successful_login(user)
      end
    end
  end

  def logout
    flash[:notice] = t(:logout)
    cookies.delete :token
    session[:user_id] = nil
    redirect_to Page.root.get_path unless Page.root.nil?
    redirect_to "/" if Page.root.nil?
  end

  private

  def open_id_authentication
    identity_url = params[:openid_identifier]
    authenticate_with_open_id(identity_url, :optinal => [ :nickname ] ) do |result, identity_url, profile|
      if result.successful?
        name = profile['nickname'] || "openid"
        user = User.find_or_create_by_username(:username => identity_url, :name => name)
        successful_login(user)
      else
        failed_login
      end
    end
  end

  def successful_login(user)
    session[:user_id] = user.id
    cookies[:token] = {:value => user.token, :expires => 1.month.from_now}
    flash[:notice] = t(:login_successful)
    redirect_to :back
  end

  def failed_login
    flash[:error] = t(:login_error)
    redirect_to :back
  end
  
end

