# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def login_path
    url_for :controller => 'users', :action => 'login'
  end

  def logout_path
    url_for :controller => 'users', :action => 'logout'
  end
end
