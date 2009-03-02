def path_to(page_name)
  case page_name
  
  when /the main page/i
    "/"
  
  when /a page without parent/i
    "/some/nested/page/"
  
  else
    raise "Can't find mapping from \"#{page_name}\" to a path."
  end
end