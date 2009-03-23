def path_to(page_name)
  case page_name
  
  when /the main page/i
    "/"
  
  when /a page without parent/i
    "/some/nested/page/"
  
  else
    page_name
  end
end