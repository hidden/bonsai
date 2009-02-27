class PagePartRevisionsController < ApplicationController
  def edit
    @page_part_revision = PagePartRevision.find(params[:id])
    @page_part = PagePart.find(params[:page_part_id])
    @page = Page.find(params[:page_id])
  end

  def update
    @page_part_revision = PagePartRevision.find(params[:id])

    @new_revision = PagePartRevision.create(:user => session[:user], :page_part => @page_part_revision.page_part, :body => params[:body])
    @page_part_revision.page_part.current_page_part_revision = @new_revision
    @page_part_revision.save!
    @page_part_revision.page_part.save!

    
    redirect_to(@page_part_revision.page_part.page.get_path + "/")
  end
end
