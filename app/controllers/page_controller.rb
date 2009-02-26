class PageController < ApplicationController
  def view
    @current_user = session[:user]
    @page = Page.find_by_path(params[:path])
    if params.include? 'edit'
      render :action => 'edit'
    elsif params.include? 'update'
      update @page
    end
  end

  private
  def edit
  end

  def update page
    params[:parts].each do |part_name, body|
      page_part = PagePart.find_by_name_and_page_id(part_name, page.id)
      unless page_part.current_page_part_revision.body == body
        revision = PagePartRevision.create(:user => @current_user, :page_part => page_part, :body => body)
        page_part.current_page_part_revision_id = revision.id
        page_part.save
      end
    end
    redirect_to params[:path].join '/'
  end
end
