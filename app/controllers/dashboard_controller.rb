class DashboardController < ApplicationController
  #prepend_before_filter :slash_check, :only => [:index]
  before_filter :can_view_dashboard_check

  def index
    if params.include? 'back'
      session[:link_back] = params['back']
      redirect_to url_for :controller => 'dashboard'
      return
    end
    render :action => :dashboard
  end

  private
  def slash_check
    link = request.env['PATH_INFO']
    unless link.ends_with?('/')
      redirect_to link + '/'
      return
    end
  end

  def can_view_dashboard_check
    unless @current_user.logged? then
      unprivileged
    end
  end

  def unprivileged
    @hide_view_in_toolbar = true
    render :action => 'unprivileged'
  end

  def bad_request
    @hide_view_in_toolbar = true
    render :action => 'bad_request'
  end

end