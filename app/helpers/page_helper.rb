module PageHelper
  def image_boolean(value, title = nil)
    return value ? image_tag("icons/accept.png", :alt => 'Yes', :title => title) : image_tag("icons/delete.png", :alt => 'No', :title => title);
  end

  def rss_url page, user
    token_string = user.token.nil? ? '' : "?token=#{user.token}"
    page.get_path + ';rss' + token_string
  end

  def link_to_page page
    link_to page.title, page.get_path
  end
end
