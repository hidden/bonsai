class PageHistoryController < ApplicationController
  def show
    @page = Page.find_by_path(params[:path])
    
    unless @current_user.can_view_page? @page then 
	@hide_view_in_toolbar = true
	render :controller => :page, :action => :unprivileged
    end

    respond_to do |format|
      format.html # show.html.erb
    end
  end

end
