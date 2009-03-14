class PageController < ApplicationController
  def handle
    @path = params[:path]
    @page = Page.find_by_path(@path)
    if @page.nil?
      render :action => :unprivileged and return unless @current_user.logged?
      params.include?('create') ? create : new
      return
    end
    
    # manager actions
    if @current_user.can_manage_page? @page
      if params.include? 'manage' then render :action => :manage and return
      elsif params.include? 'change-permission' then change_permission and return
      elsif params.include? 'set-permissions' then set_permissions and return
      elsif params.include? 'remove-permission' then remove_permission and return
      elsif params.include? 'make-public' then make_public and return
      elsif params.include? 'make-editable' then make_editable and return
      end
    end

    # editor actions
    if @current_user.can_edit_page? @page
      if params.include? 'edit' then edit and return
      elsif params.include? 'update' then update and return
      elsif params.include? 'upload' then upload and return
      elsif params.include? 'undo' then undo and return
      elsif params.include? 'new-part' then new_part and return
      end
    end

    # viewer actions
    if @current_user.can_view_page? @page
      if params.include? 'history' then render :action => :show_history and return
      elsif params.include? 'diff' then diff and return
      else render :action => :view and return
      end
    end
    render :action => 'unprivileged'
  end

  def diff
    @first_revision = @page.page_parts_revisions[params[:first_revision].to_i]
    @second_revision = @page.page_parts_revisions[params[:second_revision].to_i]
    render :action => 'diff'
  end

  def undo
    @page_revision = @page.page_parts_revisions[params[:revision].to_i]
    @page_part = @page_revision.page_part
    @undo = true
    render :action => 'edit'
  end

  def make_public
    @page.page_permissions.each do |permission|
      permission.can_view = false
      permission.save
    end
    redirect_to @page.get_path + "?manage"
  end
  
  def make_editable
    @page.page_permissions.each do |permission|
      permission.can_view = false
      permission.can_edit = false
      permission.save
    end
    redirect_to @page.get_path + "?manage"
  end

  def change_permission
    page_permission = @page.page_permissions[params[:index].to_i]
    if(params[:permission] == "can_view")
      if(page_permission.group.users.include? @current_user)
        flash[:notice] = "You cannot disable your own view permission if you are in the manager group of the page. If you want to make this page public, you should use the quick setup link below"
      else
        page_permission.can_view ? @page.remove_viewer(page_permission.group):@page.add_viewer(page_permission.group)
      end
    elsif(params[:permission] == "can_edit")
      if(page_permission.group.users.include? @current_user)
        flash[:notice] = "You cannot disable your own edit permission if you are in the manager group of the page. If you want to make this page editable by anyone, you should use the quick setup link below"
      else
        page_permission.can_edit ? @page.remove_editor(page_permission.group):@page.add_editor(page_permission.group)
      end
    elsif(params[:permission] == "can_manage")
      page_permission.can_manage ? @page.remove_manager(page_permission.group):@page.add_manager(page_permission.group)
    end
    page_permission.save
    redirect_to @page.get_path + "?manage"
  end

  def remove_permission
    page_permission = @page.page_permissions[params[:index].to_i]
    page_permission.destroy
    redirect_to @page.get_path + "?manage"
  end

  def new
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
    page = Page.new(:title => params[:title], :sid => sid)
    unless (page.valid?)
      error_message = ""
      page.errors.each_full { |msg| error_message << msg }
      flash[:notice] = error_message
      render :action => "new"
      return
    end
    page.save!
    page.add_manager @current_user.private_group
    page.move_to_child_of parent unless parent.nil?
    page_part = PagePart.create(:name => "body", :page => page, :current_page_part_revision_id => 0)
    first_revision = PagePartRevision.new(:user => @current_user, :body => params[:body], :page_part => page_part, :summary => params[:summary])
    unless (first_revision.valid?)
      error_message = ""
      first_revision.errors.each_full { |msg| error_message << msg }
      flash[:notice] = error_message
      @body = first_revision.body
      @sid = sid
      @parent_id = params[:parent_id]
      page_part.delete
      page.delete
      render :action => "new"
      return
    end
    if(first_revision.save)
      flash[:notice] = 'Page successfully created.'
      page_part.current_page_part_revision = first_revision
      page_part.save!
    end
    redirect_to page.get_path
  end

  def show_history
    if params.include? 'diff'
      render :action => "diff"
    end
  end

  private
  def edit
    render :action => :edit
  end

  def set_permissions
    groups = params[:groups][:id]
    groups.each do |group_id|
      group = Group.find(group_id)
      @page.add_viewer group if params[:can_view]
      @page.add_editor group if params[:can_edit]
      @page.add_manager group if params[:can_manage]
    end
    redirect_to @page.get_path + "?manage"
  end

  def update
    @page.title = params[:title]
    @page.save
    params[:parts].each do |part_name, body|
      page_part = PagePart.find_by_name_and_page_id(part_name, @page.id)
      current_revision = page_part.current_page_part_revision

      revision = nil
      if(page_part.current_page_part_revision.body != body ||
            current_revision.was_deleted && (params[:is_deleted].blank? || params[:is_deleted][part_name].blank?) ||
            !current_revision.was_deleted && !params[:is_deleted].blank? && !params[:is_deleted][part_name].blank?)

        revision = PagePartRevision.new(:user => @current_user, :page_part => page_part, :body => body, :summary => params[:summary])
        if(!current_revision.was_deleted && (!params[:is_deleted].blank? && !params[:is_deleted][part_name].blank?))
          revision.was_deleted = true
        end
        unless(revision.valid?)
          error_message = ""
          revision.errors.each_full { |msg| error_message << msg }
          @page_part = page_part
          @page_revision = revision
          flash[:notice] = error_message
          render :action => "edit"
          return true
        end
        revision.save!
        page_part.current_page_part_revision = revision
        page_part.save!
      end
    end
    flash[:notice] = 'Page successfully updated.'
    redirect_to @page.get_path
  end

  def new_part
    page_part = PagePart.create(:name => params[:new_page_part_name], :page => @page, :current_page_part_revision_id => 0)
    page_part_revision = PagePartRevision.new(:user => @current_user, :page_part => page_part, :body => params[:new_page_part_text], :summary => "init")
    page_part_revision.save
    page_part.current_page_part_revision = page_part_revision
    page_part.save!
    flash[:notice] = 'Page part successfully added.'
    redirect_to @page.get_path + "?edit"
  end

  def upload
    @uploaded_file = UploadedFile.new(params[:uploaded_file])
    sleep(3)
    @uploaded_file.page = @page
    @uploaded_file.user = @current_user
    if @uploaded_file.save
      flash[:notice] = 'File was successfully uploaded.'
      redirect_to @page.get_path
    else
      error_message = ""
      @uploaded_file.errors.each_full { |msg| error_message << msg }
      flash[:notice] = error_message
      render :action => :edit
    end
  end
end
