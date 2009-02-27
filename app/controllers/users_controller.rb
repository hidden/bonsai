class UsersController < ApplicationController
  def login
    return unless params[:username]
    data = SimpleLDAP.authenticate(params[:username], params[:password], 'ldap.stuba.sk', 389, 'ou=People,dc=stuba,dc=sk')
    if data.nil?
      flash[:notice] = 'Login failed'
      redirect_to :action => 'login'
    else
      user = User.find_or_create_by_username(:username => params[:username], :name => data['cn'].first)
      session[:user] = user
      redirect_to :controller => 'page', :action => 'index'
    end
  end
end
