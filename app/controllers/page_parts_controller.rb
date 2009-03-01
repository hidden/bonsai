class PagePartsController < ApplicationController
  def new
    @page = Page.find(params[:page_id])
    @page_part = PagePart.new(:page => @page)
  end

  def create
    @page_part = PagePart.new(:name => params[:part_name], :is_deleted => :false)
    @page_part.page = Page.find(params[:page_id])
    @page_part_revision = PagePartRevision.new(:page_part_id => 0, :user => session[:user], :body => params[:page_revision_body])
    @page_part.current_page_part_revision = @page_part_revision
    @page_part.save!
    @page_part_revision.page_part = @page_part
    @page_part_revision.save!
    redirect_to(@page_part.page.get_path)
    #redirect_to edit_page_page_part_page_part_revision_url(@page_part.page, @page_part, @page_part.current_page_part_revision)
  end
end
