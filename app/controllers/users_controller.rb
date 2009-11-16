class UsersController < ApplicationController
  def login
    return unless params[:username]
    authenticator = Rails.env.production? ? SimpleLDAP : SimpleLDAP::Stub
    data = authenticator.authenticate(params[:username], params[:password], 'ldap.stuba.sk', 389, 'ou=People,dc=stuba,dc=sk')
    if data.nil?
      flash[:error] = t(:login_error)
    else
      user = User.find_or_create_by_username(:username => params[:username], :name => data['cn'].first)
      session[:user_id] = user.id
      cookies[:token] = {:value => user.token, :expires => 1.month.from_now}
      flash[:notice] = t(:login_successful)
    end
    redirect_to :back
  end

  def logout
    flash[:notice] = t(:logout)
    cookies.delete :token
    session[:user_id] = nil
    redirect_to Page.root.get_path unless Page.root.nil?
    redirect_to "/" if Page.root.nil?
  end
end
