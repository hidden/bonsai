class AnonymousUser
  def initialize(session)
    @session = session
  end

  def logged?
    false
  end

  def can_view_page? page
    return page.is_public?
  end

  def can_edit_page? page
    false
  end

  def can_manage_page? page
    false
  end

  def token
    nil
  end

  def prefered_locale
    @session[:locale]
  end

  def prefered_locale=(locale)
    @session[:locale] = locale
  end

  def verify_admin_right
    return false
  end
end
