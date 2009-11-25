# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
   def markdown(text)
    text.blank? ? "" :  highlight(Maruku.new(text).to_html)
  end

  def highlight(html)
    return html.gsub(/(<pre class='[a-z0-9-]+)/,'\1;').gsub("<pre class='","<pre class='brush:").gsub(/<.?code>/," ").gsub("<pre ",'<pre ')
  end

  def login_form
    if APP_CONFIG['authentication_method'] == 'openid' then
      render :partial => 'shared/openid_login'
    else
      render :partial => 'shared/ldap_login'
    end
  end

  def icon_tag(source, options = {})
    defaults = {:alt => "", :size => "16x16"}    
    image_tag("icons/#{source}", defaults.merge(options))
  end
end
