class PageController < ApplicationController
  def view
    @current_user = session[:user]
    @path = params[:path]
    @page = Page.find_by_path(@path)
    if params.include? 'edit'
      render :action => 'edit'
    elsif params.include? 'create'
      create
    elsif @page.nil?
      new
    elsif params.include? 'update'
      update @page
    end
  end

  def new
    render :action => 'unprivileged' and return if @current_user.nil?
    if @path.empty?
      @parent_id = nil
    else
      parent_path = Array.new @path
      parent_path.pop
      parent = Page.find_by_path(parent_path)
      render :action => 'no_parent' and return if parent.nil?
      @parent_id = parent.id
    end
    @sid = @path.empty? ? nil : @path.last
    render :action => 'new'
  end

  def create
    parent = nil
    unless params[:parent_id].blank?
      parent = Page.find_by_id(params[:parent_id])
      # TODO check if exists
    end
    sid = params[:sid].blank? ? nil : params[:sid]
    page = Page.create(:title => params[:title], :sid => sid)
    page.save!
    page.move_to_child_of parent unless parent.nil?
    page_part = PagePart.create(:name => "body", :page => page, :current_page_part_revision_id => 0)
    first_revision = PagePartRevision.create(:user => session[:user], :body => params[:body], :page_part => page_part)
    page_part.current_page_part_revision = first_revision
    page_part.save!
    flash[:notice] = 'Page successfully created.'
    redirect_to page.get_path
  end

  private
  def edit
    
  end

  def update page
    page.title = params[:title]
    page.save
    params[:parts].each do |part_name, body|
      page_part = PagePart.find_by_name_and_page_id(part_name, page.id)
      page_part.is_deleted = params[:is_deleted].nil? ? nil:params[:is_deleted][part_name]
      unless page_part.current_page_part_revision.body == body
        revision = PagePartRevision.create(:user => @current_user, :page_part => page_part, :body => body)
        page_part.current_page_part_revision_id = revision.id
      end
      page_part.save
    end
    redirect_to page.get_path
  end
end
