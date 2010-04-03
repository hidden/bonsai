module PageHelper

  def get_layout_definitions
    directories =  Array.new
    Dir.glob("vendor/layouts/*") do |directory|
      if File::directory? directory
        if File.exist? ("#{directory}/definition.yml")
          directories.push directory
        end
      end
    end
    return directories
  end

  def get_layout_parameters(file)
    layout = YAML.load_file("#{file}/definition.yml")
    unless layout.nil?
      layout_value = file[(file.rindex("/")+1)..-1]
      parameters =[ layout_value, layout['name'], layout['parts'] ]
    end
    return parameters
  end


  def image_boolean(value, title = nil)
    return value ? image_tag("icons/accept.png", :alt => 'Yes', :title => title) : image_tag("icons/delete.png", :alt => 'No', :title => title);
  end

  def file_type_image_tag(file)
   icon = APP_CONFIG['extension_icons'][file.extension]
   icon = APP_CONFIG['extension_icons']['default'] if icon.nil?
   image_tag("icons/file_types/#{icon}", :size => "16x16", :alt => "")
  end

  def rss_url page, user
    token_string = user.token.nil? ? '' : "?token=#{user.token}"
    page.get_path + ';rss' + token_string
  end

   def rss_subtree_url page, user
    token_string = user.token.nil? ? '' : "?token=#{user.token}"
    page.get_path + ';rss_subtree' + token_string
  end

  def link_to_page page
    link_to page.title, page.get_path
  end
  
  def perm_hist
    url_for :controller => 'page', :action => 'permissions_history'
  end
end
