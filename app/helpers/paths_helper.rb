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

  def page_path(page, action = 'view', options = {})
    forced_options = {:controller => 'page', :action => action, :path => page.get_rel_path}
    url_for(options.merge(forced_options))
  end

  def edit_page_path(page)
    page_path(page, 'edit')
  end

  def save_edited_page_path(page)
    page_path(page, 'save_edit')
  end

  def upload_file_path(page)
    page_path(page, 'upload')
  end

  def edit_upload_file_path(page, per_page)
    page_path(page, 'upload', :redirect => 'none', :per_page => per_page)
  end

  def page_history_path(page)
    page_path(page, 'history')
  end

  def list_files_path(page)
    page_path(page, 'files')
  end

  def _remove_permission_path(page, index)
    page_path(page, 'remove_permission', :index => index)
  end

  def change_permission_path(page, index, permission)
    page_path(page, 'change_permission', :index => index, :permission => permission)
  end

  def switch_public_path(page)
    page_path(page, 'switch_public')
  end

  def switch_editable(page)
    page_path(page, 'switch_editable')
  end

  def groups_page_path
    groups_path
  end

  def dashboard_page_path
    url_for :controller => 'dashboard'
  end

  def toggle_news
    url_for :controller => "dashboard", :action => "toggle_news"
  end

  def file_history_page_path(page, name)
    url_for(:controller => 'page', :action => 'history', :path => page.get_rel_path + [name])
  end

  def admin_page_path
    admin_path
  end

  def admin_page_path_sort(grid_page,order)
    admin_path(:page=>grid_page,:order => order)
  end

  def rss_path(page, user)
    page_path(page, 'rss', :token => user.token)
  end

   def rss_tree_path(page, user)
     page_path(page, 'rss_tree', :token => user.token)
   end

    def add_page_path(page)
     page_path(page,'add')
    end

  def render_files_path(page, per_page, upscale = nil, ok = nil, order = nil)
    if(order.nil?)
      order = (!session[:sort].nil? && session[:sort].eql?('name')) ? 'name' : 'date'
    else
      change = true
    end
    page_path(page, 'render_files', :per_page => per_page, :success => ok, :upscale => upscale, :order => order, :change => change)
  end

  def skuska_path
    url_for :controller => "page", :action => "test_metoda"
  end
end