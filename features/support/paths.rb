def path_to(page_name)
  case page_name

    when /the main page/i
      "/"

    when /the test page/i
      "/test/"

    when /a page without parent/i
      "/some/nested/page/"

    when /the registration page/i
      "/w/users/new/"

    else
      page_name
  end
end

#World(NavigationHelpers)
