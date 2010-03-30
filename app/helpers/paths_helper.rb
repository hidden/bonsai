module PathsHelper
  def login_path
    if APP_CONFIG['force_https']
      url_for :controller => 'users', :action => 'login', :only_path => false, :protocol => 'https'
    else
      url_for :controller => 'users', :action => 'login'            
    end
  end

  def logout_path
    url_for :controller => 'users', :action => 'logout'
  end

  def toggle_favorite_page_path(page)
    url_for :controller => "page", :action => "toggle_favorite"
  end

  def remove_page_part_path(page, id)
     url_for :controller => "page", :action => "remove_page_part", :part_id => id
  end

  def edit_page_path(page)
    "#{page.get_path};edit"
  end

  def update_page_path(page)
    "#{page.get_path};update"
  end

  def save_edited_page_path(page)
    "#{page.get_path};save_edit"
  end

  def upload_file_path(page)
    "#{page.get_path};upload"
  end

  def page_history_path(page)
   "#{page.get_path};history"
  end

  def manage_page_path(page)
    "#{page.get_path};manage"
  end

  def list_files_path(page)
    "#{page.get_path};files"
  end

  def _remove_permission_path(page, index)
    "#{page.get_path};remove_permission?index=#{index}"
  end

  def change_permission_path(page, index, permission)
    "#{page.get_path};change_permission?index=#{index}&permission=#{permission}"
  end

  def switch_public_path(page)
    "#{page.get_path};switch_public"
  end

  def switch_editable(page)
    "#{page.get_path};switch_editable"
  end

  def view_page_path(page)
    page.get_path
  end

  def summary_page_path(page)
    "#{page.get_path};pagesib"
  end

  def groups_page_path(page)
    groups_path(:back => page.get_path)
  end

  def dashboard_page_path(page)
    url_for :controller => 'dashboard', :back => page.get_path
  end

  def file_history_page_path(page, name)
    "#{page.get_path}#{name};history"
  end

  def admin_page_path
     "#{admin_path}?back=/"
  end

end