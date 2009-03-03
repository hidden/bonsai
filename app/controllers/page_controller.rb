class PageController < ApplicationController
  def view
    @current_user = session[:user]
    @path = params[:path]
    @page = Page.find_by_path(@path)
    if params.include? 'edit'
      render :action => 'edit'
    elsif params.include? 'create'
      create
    elsif params.include? 'undo'
      @page_part = PagePart.find(params[:page_part])
      @page_revision = PagePartRevision.find(params[:revision])
      render :action => 'edit'
    elsif params.include? 'history'
      render :action => 'show_history'
    elsif params.include? 'diff'
      @first_revision = PagePartRevision.find(params[:first_revision])
      @second_revision = PagePartRevision.find(params[:second_revision])
      render :action => 'diff'
    elsif @page.nil?
      new
    elsif params.include? 'update'
      update @page
    elsif params.include? 'add_page_part'
      add_new_page_part @page
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
    ActiveRecord::Base.transaction do
      page = Page.new(:title => params[:title], :sid => sid)
      unless (page.valid?)
        error_message = ""
        page.errors.each_full { |msg| error_message << msg }
        flash[:notice] = error_message
        redirect_to page.get_path
      end
      page.save!
      page.move_to_child_of parent unless parent.nil?
      page_part = PagePart.create(:name => "body", :page => page, :current_page_part_revision_id => 0)
      first_revision = PagePartRevision.new(:user => session[:user], :body => params[:body], :page_part => page_part, :summary => params[:summary])
      unless (first_revision.valid?)
        error_message = ""
        first_revision.errors.each_full { |msg| error_message << msg }
        flash[:notice] = error_message
        page_part.delete
        page.delete
        redirect_to page.get_path
      end
      if(first_revision.save)
        flash[:notice] = 'Page successfully created.'
        page_part.current_page_part_revision = first_revision
        page_part.save!
      else
        raise ActiveRecord::Rollback
      end
      redirect_to page.get_path
    end
  end

  def show_history
    if params.include? 'diff'
      render :action => "diff"
    end
  end 

  private
  def edit
    
  end

  def update page
    page.title = params[:title]
    page.save
    params[:parts].each do |part_name, body|
      page_part = PagePart.find_by_name_and_page_id(part_name, page.id)
      current_revision = page_part.current_page_part_revision

      revision = nil
      if(page_part.current_page_part_revision.body != body ||
            current_revision.was_deleted && (params[:is_deleted].blank? || params[:is_deleted][part_name].blank?) ||
            !current_revision.was_deleted && !params[:is_deleted].blank? && !params[:is_deleted][part_name].blank?)

        revision = PagePartRevision.new(:user => @current_user, :page_part => page_part, :body => body, :summary => params[:summary])
        if(!current_revision.was_deleted && (!params[:is_deleted].blank? && !params[:is_deleted][part_name].blank?))
          revision.was_deleted = 1
        end
        unless(revision.valid?)
          error_message = ""
          revision.errors.each_full { |msg| error_message << msg }
          flash[:notice] = error_message
          redirect_to page.get_path + "?edit"
          return
        end
        revision.save!
        page_part.current_page_part_revision = revision
        page_part.save!
      end
    end
    flash[:notice] = 'Page successfully updated.'
    redirect_to page.get_path
  end

  def add_new_page_part page
    page_part = PagePart.create(:name => params[:new_page_part_name], :page => page, :current_page_part_revision_id => 0)
    page_part_revision = PagePartRevision.new(:user => @current_user, :page_part => page_part, :body => params[:new_page_part_text], :summary => "init")
    page_part_revision.save
    page_part.current_page_part_revision = page_part_revision
    page_part.save!
    flash[:notice] = 'Page part successfully added.'
    redirect_to page.get_path + "?edit"
  end
end
