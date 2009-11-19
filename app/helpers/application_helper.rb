# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def login_path
    url_for :controller => 'users', :action => 'login'
  end

  def logout_path
    url_for :controller => 'users', :action => 'logout'
  end

  def edit_page_path(page)
    "#{page.get_path};edit"
  end

  def update_page_path(page)
    "#{page.get_path};update"
  end

  def upload_file_path(page)
    "#{page.get_path};upload"
  end

  def page_history_path(page)
   "#{page.get_path};show_history"
  end

  def manage_page_path(page)
    "#{page.get_path};manage"
  end

  def list_files_path(page)
    "#{page.get_path};files"
  end

  def remove_permission_path(page, index)
    "#{page.get_path}?remove_permission&index=#{index}"
  end

  def change_permission_path(page, index, permission)
    "#{page.get_path};change_permission?index=#{index}&permission=#{permission}"
  end

  def switch_public_path(page)
    "#{page.get_path};switch_public"
  end

  def switch_editable(page)
    "#{@page.get_path};switch_editable"
  end

  def view_page_path(page)
    page.get_path
  end

  def summary_page_path(page)
    "#{page.get_path};pagesib"
  end

  def groups_page_path(page)
    groups_path+"?back=#{page.get_path}"
  end

   def markdown(text)
    text.blank? ? "" :  hihtlight(Maruku.new(text).to_html)
  end

  def hihtlight(text)
    return text.gsub(/(<pre class='[a-z0-9-]+)/,'\1:nogutter:nocontrols').gsub(/<.?code>/," ").gsub("<pre ",'<pre name="code" ')
  end

  def login_form
    if APP_CONFIG['authentication_method'] == 'openid' then
      render :partial => 'shared/openid_login'
    else
      render :partial => 'shared/ldap_login'
    end
  end
end
