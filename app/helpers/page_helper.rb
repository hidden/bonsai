module PageHelper

  def image_boolean(value, title = nil)
    return value ? image_tag("icons/accept.png", :alt => 'Yes', :title => title) : image_tag("icons/delete.png", :alt => 'No', :title => title);
  end

  def file_type_image_tag(file)
   icon = APP_CONFIG['extension_icons'][file.extension_type]
   icon = APP_CONFIG['extension_icons']['default'] if icon.nil?
   image_tag("icons/file_types/#{icon}", :size => "16x16", :alt => "")
  end

  def link_to_page(page)
    link_to page.title, page_path(page)
  end
  
  def perm_hist
    url_for :controller => 'page', :action => 'permissions_history'
  end
end
