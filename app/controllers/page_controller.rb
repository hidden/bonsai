class PageController < ApplicationController
  def view
    @current_user = session[:user]
    @path = params[:path]
    @sid = @path.last
    @page = Page.find_by_path(@path)
    @creating_root = false
    if(@page.nil?)
      if(@current_user.nil?)
        render :action => 'unprivileged'
        return
      end
      #does parent exist?
      if(@path.size > 0)
        @path.pop
        @parent = Page.find_by_path @path
        if(@parent.nil?)
          #we do not want to create a page in the middle of nowhere
        else
          @parent_id = @parent.id
          render :action => 'new'
        end
      elsif(Page.root.nil?)
        @creating_root = true
        @sid = nil
        render :action => 'new'
      end
    end
    if params.include? 'edit'
      render :action => 'edit'
    elsif params.include? 'update'
      update @page
    end
  end

  def create
    @parent = nil
    @parent = Page.find(params[:parent_id]) unless params[:creating_root] == "true"
    @sid = nil
    @sid = params[:sid].downcase.gsub(/ /,'') unless params[:sid].nil?
    @page = Page.create(:title => params[:title], :sid => @sid)
    @page.move_to_child_of @parent unless @parent.nil?
    @first_revision = PagePartRevision.create(:user => session[:user], :body => params[:body], :page_part_id => 0)
    @page_part = PagePart.create(:name => "body", :page => @page, :current_page_part_revision => @first_revision)
    @first_revision.page_part = @page_part
    @first_revision.save!
    flash[:notice] = 'Page successfully created.'
    redirect_to @page.get_path
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
    redirect_to('/' + params[:path].join('/'))
  end
end
