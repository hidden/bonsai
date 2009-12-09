module UsersHelper
  def change_locale(locale)
    url_for :controller => 'users', :action => 'save_locale', :locale => locale
  end
end
