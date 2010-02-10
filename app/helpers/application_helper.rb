# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def markdown(text)
    text.blank? ? "" : syntax_highlight(Maruku.new(text).to_html)
  end

  def syntax_highlight(html)
    html.gsub(/(<pre class='[a-z0-9-]+)/, '\1;').gsub("<pre class='", "<pre class='brush:").gsub(/<.?code>/, " ").gsub("<pre ", '<pre ')
  end

  def highlight(text, phrases, *args)
    options = args.extract_options!
    unless args.empty?
      options[:highlighter] = args[0] || '<strong class="highlight">\1</strong>'
    end
    options.reverse_merge!(:highlighter => '<strong class="highlight">\1</strong>')

    if text.blank? || phrases.blank?
      text
    else
      haystack = text.clone
      match = Array(phrases).map { |p| Regexp.escape(p) }.join('|')
      if options[:ignore_special_chars]
        haystack = haystack.mb_chars.normalize(:kd)
        match = match.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]+/n, '').gsub(/\w/, '\0[^\x00-\x7F]*')
      end
      highlighted = haystack.gsub(/(#{match})(?!(?:[^<]*?)(?:["'])[^<>]*>)/i, options[:highlighter])
      highlighted = highlighted.mb_chars.normalize(:kc) if options[:ignore_special_chars]
      return highlighted
    end
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
