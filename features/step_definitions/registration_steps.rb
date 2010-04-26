When /^the user registration is ([^"]*)$/ do |option|
  case option
    when "disabled"
      APP_CONFIG['allow_user_registration'] = false
    when "enabled"
      APP_CONFIG['allow_user_registration'] = true
  end
end