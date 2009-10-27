# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def login_path
    url_for :controller => 'users', :action => 'login'
  end

  def logout_path
    url_for :controller => 'users', :action => 'logout'
  end

  def edit_page_path(page)
    "#{page.get_path}?edit"
  end

  def upload_file_path(page)
    "#{page.get_path}?upload"
  end

  def markdown(text)
    text.blank? ? "" : Maruku.new(text).to_html
  end
end
