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

  def update_page_path(page)
    "#{page.get_path}?update"
  end

  def upload_file_path(page)
    "#{page.get_path}?upload"
  end

  def history_page_path(page)
    "#{page.get_path}?history"
  end

  def manage_page_path(page)
    "#{page.get_path}?manage"
  end

  def files_page_path(page)
   "#{page.get_path}?files"
  end

  def view_page_path(page)
    page.get_path
  end

  def groups_page_path(page)
    "#{page.get_path}?groups"
  end

  def markdown(text)
    text.blank? ? "" : Maruku.new(text).to_html
  end
end
