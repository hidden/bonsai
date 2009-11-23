#xhtml validation
require "markup_validity" if ENV["VALIDATION"]

Then /this page is XHTML valid/ do
  response.body.should be_xhtml_strict if ENV["VALIDATION"]
end
