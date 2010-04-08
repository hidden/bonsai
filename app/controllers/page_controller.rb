class PageController < ApplicationController
  before_filter :load_page, :except => [:add_lock, :update_lock, :search]
  before_filter :can_manage_page_check, :only => [:manage, :change_permission, :set_permissions, :remove_permission, :switch_public, :switch_editable]
  before_filter :can_edit_page_check, :only => [:edit, :update, :upload, :undo, :new_part, :files]
  before_filter :check_file, :only => [:view]
  before_filter :slash_check, :only => [:view]
  before_filter :is_blank_page, :only => [:view]
  before_filter :can_view_page_check, :only => [:view, :history, :revision, :diff, :toggle_favorite]
  around_filter :rss_view_check, :only => [:rss, :rss_tree]

  def search
    @query = params[:q]
    @search_results = Page.search(
            @query,
            :with => {:page_ids => @current_user.find_all_accessible_pages.collect(&:id)},
            :page => params[:page]
    )
  end

  def permissions_history
    @permissions_history = PagePermissionsHistory.paginate( :all, :conditions => {:page_id => @page.id}, :include => [:user, :group], :per_page => 20, :page => params[:page], :order => 'id DESC')
    @no_toolbar = true
  end
  
  def view
    @hide_view_in_toolbar = true
    layout = @page.nil? ? 'application' : @page.resolve_layout
    render :action => :view, :layout => layout
  end

  def unprivileged
    @hide_view_in_toolbar = true
    render :action => :unprivileged
  end

  def history
    if is_file(@path)
      @file = @page.uploaded_files.find_by_filename(@path.last)
      render :action => :file_history
    else
      render :action => :show_history
    end
  end

  def diff
    page = PageAtRevision.find_by_path(@path)

    first_revision = params[:first_revision]
    second_revision = params[:second_revision]
    if (first_revision.to_i < second_revision.to_i)
      first = second_revision
      second = first_revision
    else
      second = second_revision
      first = first_revision
    end

    revision1 = page.page_parts_revisions[first.to_i].id
    old_revision = ""
    for part in page.page_parts
      revision = part.page_part_revisions.first(:conditions => ["id <= ?", revision1])
      unless revision.nil? or revision.was_deleted?
        old_revision << revision.body << "\n"
      end
    end

    new_revision = ""
    revision2 = page.page_parts_revisions[second.to_i].id
    for part in page.page_parts
      revision = part.page_part_revisions.first(:conditions => ["id <= ?", revision2])
      unless revision.nil? or revision.was_deleted?
        new_revision << revision.body << "\n"
      end
    end
    @changes = SimpleDiff.diff(old_revision, new_revision)
    render :action => 'diff'
  end

  def revision
    @page = PageAtRevision.find_by_path(@path)

    revision_date = @page.page_parts_revisions[params[:revision].to_i].created_at
    @page.revision_date = revision_date
    @page_parts = Array.new

    for part in @page.page_parts
      current_part = part.page_part_revisions.find(:first, :conditions => ['created_at <= ?', revision_date])
      @page_parts << current_part if current_part
    end
    layout = @page.nil? ? 'application' : @page.resolve_layout

    render :action => 'show_revision', :layout => layout
  end

  def undo
    @page_revision = @page.page_parts_revisions[params[:revision].to_i]
    @page_part = @page_revision.page_part
    @undo = true
    render :action => 'edit'
  end

  def switch_public
    was_public = @page.is_public?
    if (@page.is_public?)
      ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => 0, :role => 1, :action => 2)
    else
      ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => 0, :role => 1, :action => 1)
    end
    if (@page.parent.nil? || @page.parent.is_public?)
      @page.page_permissions.each do |permission|
        permission.can_view = was_public
        permission.can_edit = was_public if was_public
        #TODO: if the @page has some public descendants, we should spread the switch to them as well
        permission.save
      end
    end
    ph.save
    #redirect_to manage_page_path(@page)
  end

  def switch_editable
    was_editable = @page.is_editable?
    if (@page.is_editable?)
      ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => 0, :role => 2, :action => 2)
    else
      ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => 0, :role => 2, :action => 1)
    end
    if (@page.parent.nil? || @page.parent.is_public?)
      @page.page_permissions.each do |permission|
        permission.can_view = was_editable if !was_editable
        permission.can_edit = was_editable
        #TODO: if the @page has some public descendants, we should spread the switch to them as well
        permission.save
      end
    end
    ph.save
    #redirect_to manage_page_path(@page)
  end

  def change_permission
    page_permission = @page.page_permissions[params[:index].to_i]
    if (params[:permission] == "1")
      #if (page_permission.group.users.include? @current_user)
      #  flash[:notice] = t(:can_view_error)
      #else
      #page_permission.can_view ? @page.remove_viewer(page_permission.group):@page.add_viewer(page_permission.group)
      unless @managers < 2 && page_permission.can_manage?


        #znizenie prav, ak pouzivatel nejake mal
        if (page_permission.can_manage?)
          @page.remove_manager(page_permission.group)
          ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 3, :action => 2)
          ph.save
          @managers -= 1
        end
        if (page_permission.can_edit?)
          @page.remove_editor(page_permission.group)
          ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 2, :action => 2)
          ph.save
        end
        if (!page_permission.can_view?)
          @page.add_viewer(page_permission.group)
          ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 1, :action => 1)
          ph.save
        end
      end
      #end
    elsif (params[:permission] == "2")
      #if (page_permission.group.users.include? @current_user)
      #  flash[:notice] = t(:can_edit_error)
      #else
      #page_permission.can_edit ? @page.remove_editor(page_permission.group):@page.add_editor(page_permission.group)


      #znizenie prav, ak pouzivatel nejake mal
      unless @managers < 2 && page_permission.can_manage?
        if (page_permission.can_manage?)
          @page.remove_manager(page_permission.group)
          @page.add_editor(page_permission.group)
          ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 3, :action => 2)
          ph.save
          @managers -= 1
        end
        if (!page_permission.can_edit?)
          @page.add_editor(page_permission.group)
          ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 2, :action => 1)
          ph.save
        end
      end
      #end
    elsif (params[:permission] == "3")
      #page_permission.can_manage ? @page.remove_manager(page_permission.group):@page.add_manager(page_permission.group)
      if (!page_permission.can_manage?)
        @page.add_manager(page_permission.group)
        @managers += 1
        ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 3, :action => 1)
        ph.save
      end
    end
    page_permission.save
    #redirect_to manage_page_path(@page)
  end

  def remove_permission
    page_permission = @page.page_permissions[params[:index].to_i]

    if (page_permission.can_manage?)
      ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 3, :action => 2)
      ph.save
    end
    if (page_permission.can_edit?)
      ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 2, :action => 2)
      ph.save
    end
    if (page_permission.can_view?)
      ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 1, :action => 2)
      ph.save
    end

    page_permission.destroy
    #redirect_to manage_page_path(@page)
  end

  def process_file
    @no_toolbar = true

    parent_page_path = @path.clone
    @filename = parent_page_path.pop
    @page = Page.find_by_path(parent_page_path)

    return render(:action => :file_not_found) if @page.nil?
    return render(:action => :unprivileged) if !@current_user.can_view_page? @page

    @file = @page.uploaded_files.find_by_filename(@filename)
    return render(:action => :file_not_found) if @file.nil?

    file_version = params.include?(:version) ? @file.versions.find_by_version(params[:version]) : @file.current_file_version

    if params.include?(:upload) then
      upload and return
    end
    opts = {:type => file_version.content_type, :disposition => 'inline'}
    opts[:filename] = @file.filename if @file.current_file_version == file_version
    send_file(file_version.filename_with_path_and_version, opts)
  end

  def parent_layout
    if @path.empty?
      layout_id = nil
    else
      parent_path = Array.new @path
      parent_path.pop
      parent = Page.find_by_path(parent_path)
      render :action => 'no_parent' and return if parent.nil?
      layout_id = parent.layout.to_s
    end

    if layout_id.nil?
      node_with_layout = Page.first(:conditions => ["(? BETWEEN lft AND rgt) AND layout IS NOT NULL", parent.lft], :order => "lft DESC")
      return (node_with_layout.nil? ? 'default' : node_with_layout.layout)
    end
  end

  def new
    if @path.empty?
      @parent_id = nil
      @parent_layout = nil
    else
      parent_path = Array.new @path
      parent_path.pop
      parent = Page.find_by_path(parent_path)
      render :action => 'no_parent' and return if parent.nil?
      @parent_id = parent.id
      @parent_layout = parent.layout
    end

    unless @parent_id.nil?
      if @parent_layout.nil?
        node_with_layout = Page.first(:conditions => ["(? BETWEEN lft AND rgt) AND layout IS NOT NULL", parent.lft], :order => "lft DESC")
        @parent_layout =  (node_with_layout.nil? ? 'default' : node_with_layout.layout)
      end
    end

    if (!@parent_id.nil? && !(@current_user.can_edit_page? Page.find_by_id(@parent_id)))
      unprivileged
    else
      @sid = @path.empty? ? nil : @path.last
      render :action => 'new'
    end
  end

  def create
    if params['commit'].eql?('Preview')
      generate_preview
      return
    end
    parent = nil
    unless params[:parent_id].blank?
      parent = Page.find_by_id(params[:parent_id])
      # TODO check if exists
    end

    if ((!parent.nil? && !(@current_user.can_edit_page? parent)) || params[:title].nil?)
      unprivileged
    else
      sid = params[:sid].blank? ? nil : params[:sid]
      layout = params[:layout].empty? ? nil : params[:layout]
      page = Page.new(:title => params[:title], :sid => sid, :layout => layout)
      unless (page.valid?)
        error_message = ""
        page.errors.each_full { |msg| error_message << msg }
        flash[:notice] = error_message
        render :action => "new"
        return
      end
      page.save!
      page.add_manager @current_user.private_group
      ph = PagePermissionsHistory.new(:page_id => page.id, :user_id => @current_user.id, :group_id => @current_user.private_group.id, :role => 3, :action => 1)
      ph.save
      page.move_to_child_of parent unless parent.nil?
      page_part = page.page_parts.create(:name => "body", :current_page_part_revision_id => 0)
      first_revision = page_part.page_part_revisions.create(:user => @current_user, :body => params[:body], :summary => params[:summary])
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
      if (first_revision.save)
        flash[:notice] = t(:page_created)
        page_part.current_page_part_revision = first_revision
        page_part.save!
      end
      redirect_to page.get_path
    end
  end

  def rss
    @recent_revisions = PagePartRevision.all(:include => [:page_part, :user], :conditions => ["page_parts.page_id = ?", @page.id], :limit => 10, :order => "page_part_revisions.id DESC")
    @revision_count = @page.page_parts_revisions.count
    render :layout => false
  end

  def rss_tree
    ids =  @current_user.find_all_accessible_pages.collect(&:id)
    @recent_revisions = PagePartRevision.all(:joins => [{:page_part => :page}, :user], :conditions => ["page_parts.page_id IN (?) AND pages.lft >= ? AND pages.rgt <= ?", ids, @page.lft, @page.rgt], :limit => 10, :order => "page_part_revisions.id DESC")
    @revision_count = @page.page_parts_revisions.count
    render :layout => false
  end

  def edit
    render :action => :edit
  end

  def set_permissions
    addedgroups = params[:add_group].split(",")
    for addedgroup in addedgroups
      groups = Group.find_all_by_name(addedgroup)
      unless groups.any? then
        #create user group
        tmp_user = User.create(:username => addedgroup, :name => "#{addedgroup} (tmp)")
        groups = [tmp_user.user_group]
      end
      for group in groups
        users = group.users
        retVal = group.is_public?
        retValUsers = users.include?(@current_user)
        if (retVal || retValUsers)
          @page.add_viewer group if params[:group_role][:type] == "1"
          @page.add_editor group if params[:group_role][:type] == "2"
          if params[:group_role][:type] == "3"
            @page.add_manager group
            @managers += 1
          end
          ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => group.id, :role => params[:group_role][:type], :action => 1)
          ph.save
        end
      end
    end
    #redirect_to manage_page_path(@page)
  end

  def remove_page_part
    part_id = params[:part_id]
    if not part_id.nil?
      PagePart.delete(part_id)
    end
  end


  def save_edit
    if params['commit'].eql?('Preview')
      generate_preview
      return
    end
    if params[:parts].nil?
      unprivileged
      return
    end
    @error_flash_msg = ""
    @notice_flash_msg = ""
    @managers = 0;
    @page.page_permissions.each_with_index do |permission, index|
      if permission.can_manage?
        @managers += 1
      end
    end
    @page.page_permissions.each_with_index do |permission, index|
      group_name_select = permission.group.name + "_select"
      value = params[group_name_select]
      if not value.nil?

        params[:index] = index
        params[:permission] = value

        #ak je stranka public a zo selectu vyberiem "viewer" -> nic sa neudeje a zaroven, ak je stranka editable - vsetci maju pravu edit a zo selectu vyberiem "viewer"
        #alebo "editor", tak sa tiez nic neuduje
        if ( !(@page.is_public? && params[:permission] == "1") && !(@page.is_editable? && (params[:permission] == "1" || params[:permission] == "2")))
          change_permission

          #2 specialne pripady, nie uplne stastne riesenie
          # 1.pripad, zmena managera na editora ak je stranka editable
          # 2.pripad, zmena editora/managera na viewera ak je stranka public
        else
          if @page.is_editable? && params[:permission] == "2" && permission.can_manage? && @managers >= 2
            @page.remove_manager(permission.group)
            @managers -= 1
          else
            if @page.is_public? && params[:permission] == "1"
              if @page.can_manage? && @managers >= 2
                @page.remove_manager(permission.group)
                @managers -= 1
              end
              if @page.can_edit?
                @page.remove_editor(permission.group)
              end
            end
          end
        end
      end
    end

    #add group permission from autocomplete
    if not params[:add_group].nil?
      set_permissions
    end

    #set page public or editable, ale bordel kod, toto by sa snad dalo napisat aj krajsie
    if params[:everyone_select] == "1" && !@page.is_public?
      switch_public
    else
      if params[:everyone_select] == "2" && !@page.is_editable?
        switch_editable
      else
        if params[:everyone_select] == "-"
          if @page.is_editable?
            switch_editable
          else
            if  @page.is_public?
              switch_public
            end
          end
        end
      end
    end

    # TODO refactor
    unless params[:file_version][:uploaded_data].blank?
      tmp_file = params[:file_version][:uploaded_data]
      filename = File.basename(tmp_file.original_filename)
      do_upload(tmp_file, filename)
      @notice_flash_msg = t('file_uploaded')
    end

    if not (params[:new_page_part_name].empty? and params[:new_page_part_text].empty?)
      new_part
    end

    update

    flash[:error] = @error_flash_msg unless @error_flash_msg.empty?
    flash[:notice] = @notice_flash_msg unless @notice_flash_msg.empty?
    redirect_to @page.get_path
  end

  def update
    @num_of_changed_page_parts = 0
    @page.title = params[:title]
    if @current_user.can_manage_page? @page
      @page.layout = params[:layout].empty? ? nil : params[:layout]
    end

    @page.save
    params[:parts].each do |part_name, body|

      page_part = PagePart.find_by_name_and_page_id(part_name, @page.id)
      PagePartLock.delete_lock(page_part.id, @current_user)
      new_part_name = params["parts_name"][part_name]

      edited_revision_id = params["parts_revision"][part_name]
      #delete_part = params[:is_deleted].blank? ? false : !params[:is_deleted][part_name].blank?
      delete_part = false

      edited_revision = page_part.page_part_revisions.find(:first, :conditions => {:id => edited_revision_id})

      #for each page_part we check if there was not created newer revision
      newest_revisions = page_part.page_part_revisions.first(:conditions => {:page_part_id => page_part.id})

      if (newest_revisions.id > edited_revision_id.to_i)
        @num_of_changed_page_parts += 1
      end

      # update if part name changed
      if new_part_name != part_name
        # TODO validation?
        page_part.name = new_part_name
        page_part.save
      end

      # create new revision if
      # part body was edited
      # or current revision deletion status is different # TODO ok?
      if edited_revision.body != body or page_part.current_page_part_revision.was_deleted != delete_part
        revision = page_part.page_part_revisions.create(:user => @current_user, :body => body, :summary => params[:summary], :was_deleted => delete_part)
        unless (revision.valid?)
          error_message = ""
          revision.errors.each_full { |msg| error_message << msg }
          @page_part = page_part
          @page_revision = revision
          if params[:non_redirect].nil?
            flash[:error] = error_message
            render :action => :edit
          else
            @error_flash_msg = @error_flash_msg + error_message + "\r\n"
          end
          return true
        end
        revision.save!
        page_part.current_page_part_revision = revision
        page_part.name = new_part_name
        page_part.save!
      end
    end

    if @num_of_changed_page_parts > 0 then
      notice = t(:page_updated_with_new_revisions)
    else
      notice = t(:page_updated)
    end
    if params[:non_redirect].nil?
      flash[:notice] = notice
      redirect_to @page.get_path
    else
      @notice_flash_msg = @notice_flash_msg + notice + "\r\n"
    end
  end


  def new_part
    page_part = @page.page_parts.find_or_create_by_name(:name => params[:new_page_part_name], :current_page_part_revision_id => 0)
    unless page_part.valid?
      error_message = ""
      page_part.errors.each_full { |msg| error_message << msg }
      if params[:non_redirect].nil?
        flash[:error] = error_message
        render :action => :edit
      else
        @error_flash_msg += error_message + "\r\n"
      end
      return true
    end
    page_part_revision = page_part.page_part_revisions.create(:user => @current_user, :body => params[:new_page_part_text], :summary => "init")
    page_part_revision.save
    page_part.current_page_part_revision = page_part_revision
    page_part.save!
    if params[:non_redirect].nil?
      flash[:notice] = t(:page_part_added)
      redirect_to edit_page_path(@page)
    else
      @notice_flash_msg += t(:page_part_added) + "\r\n"
    end
  end

  def upload
    @notice_flash_msg = "" if @notice_flash_msg.blank?
    tmp_file = params[:file_version][:uploaded_data]
    filename = File.basename(tmp_file.original_filename)
    target_filename = params[:uploaded_file_filename]
    if !target_filename.blank? and (File.extname(filename) != File.extname(target_filename))
      @notice_flash_msg += t('file_not_match') + "\r\n"
    else
      filename = target_filename unless target_filename.blank?
      do_upload(tmp_file, filename)
      @notice_flash_msg += t('file_uploaded') + "\r\n"
    end
    flash[:notice] = @notice_flash_msg
    redirect_to list_files_path(@page)
  end

  def do_upload(tmp_file, filename)
    unless @page.children.find_by_sid(filename).nil?
      flash[:error] = t('same_as_page')
      return
    end
    # TODO move somewhere else
    file = @page.uploaded_files.find_or_initialize_by_filename(filename)
    file.page = @page
    version = file.versions.build
    version.file = file
    version.content_type = tmp_file.content_type
    version.size = File.size(tmp_file.local_path)
    version.uploader = @current_user
    version.version = file.versions.count + 1
    target = version.filename_with_path_and_version
    folder = File.dirname(target)
    FileUtils.mkdir_p(folder) unless File.exists?(folder)
    FileUtils.copy(tmp_file.local_path, target)
    file.current_file_version_id = 0
    version.save!
    file.current_file_version = version
    file.save!
  end

  def toggle_favorite
    active = @current_user.favorite_pages.include?(@page)
    if active
      @current_user.favorite_pages.delete(@page)
    else
      @current_user.favorites.create(:page => @page)
    end

    respond_to do |format|
      format.js do
        render :update do |page|
          page.replace_html 'favorite', :partial => 'shared/favorite'
        end
      end
      format.html { redirect_to @page.get_path }
    end
  end

  def add_lock
    @add_part_id = params[:part_id]
    @add_part_name = PagePart.find(@add_part_id).name
    @editedbyanother = PagePartLock.check_lock?(@add_part_id, @current_user)
    if !@editedbyanother then
      PagePartLock.create_lock(@add_part_id, @current_user)
    end

  end

  def update_lock
    @up_part_id = params[:part_id]
    PagePartLock.create_lock(@up_part_id, @current_user)
  end

  private
  def generate_preview
    parent = nil
    unless params[:parent_id].blank?
      parent = Page.find_by_id(params[:parent_id])
      # TODO check if exists
    end

    if ((!parent.nil? && !(@current_user.can_edit_page? parent)) || params[:title].nil?)
      unprivileged
    else
      sid = params[:sid].blank? ? nil : params[:sid]
      old_page = @page
      @page = PreviewPage.new(:title => params[:title], :sid => sid, :parent_id => params[:parent_id])
      if !params[:layout].nil?
        if old_page.nil?
          layout = params[:layout].empty? ? @page.resolve_parent_layout : params[:layout]
        else
          layout = params[:layout].empty? ? old_page.resolve_parent_layout : params[:layout]
        end
      else
        layout = old_page.layout
      end
      @page.layout = layout
      params[:body].nil? ? params[:parts].each do |name, body|
        page_part = @page.page_parts.build(:name => name, :current_page_part_revision_id => 0)
        first_revision = page_part.page_part_revisions.build(:user => @current_user, :body => body, :was_deleted => false)
        page_part.current_page_part_revision = first_revision
      end : begin
        page_part = @page.page_parts.build(:name => "body", :current_page_part_revision_id => 0)
        first_revision = page_part.page_part_revisions.build(:user => @current_user, :body => params[:body], :was_deleted => false)
        page_part.current_page_part_revision = first_revision
      end

      unless (params[:new_page_part_name].nil? || params[:new_page_part_name].empty?)
        page_part = @page.page_parts.build(:name => params[:new_page_part_name], :current_page_part_revision_id => 0)
        first_revision = page_part.page_part_revisions.build(:user => @current_user, :body => params[:new_page_part_text], :was_deleted => false)
        page_part.current_page_part_revision = first_revision
      end
      @page.page_parts.sort! {|x, y| x.name <=> y.name }
      @preview_toolbar = true
      render :action => :preview, :layout => layout
    end
  end

  def load_page
    @path = params[:path]
    @page = Page.find_by_path(@path)
    session[:link_back] = nil unless session[:link_back].nil? # TODO wtf?
  end

  def can_manage_page_check
    unprivileged unless !@page.nil? && @current_user.can_manage_page?(@page)
  end

  def can_edit_page_check
    unprivileged unless !@page.nil? && @current_user.can_edit_page?(@page)
  end

  def can_view_page_check
    if is_file(@path)
      parent_path = @path.clone
      parent_path.pop
      @page = Page.find_by_path(parent_path)
    end
    unprivileged unless !@page.nil? && @current_user.can_view_page?(@page)
  end

  def rss_view_check
    user_from_token = User.find_by_token params[:token]
    user_from_token = AnonymousUser.new(session) if user_from_token.nil?
    if user_from_token.can_view_page? @page
      yield
    else
      render :nothing => true, :status => :forbidden
    end
  end  

  def slash_check
    link = request.env['PATH_INFO']
    unless link.ends_with?('/')
      redirect_to link + '/'
      return
    end
  end

  def check_file
    process_file if is_file(@path)
  end

  def is_file(path)
    return false if path.empty?
    parent_path = path.clone
    filename = parent_path.pop
    return true if filename.include?('.')
    page = Page.find_by_path(parent_path)
    return false if page.nil?
    return !page.uploaded_files.find_by_filename(filename).nil?
  end

  def is_blank_page
    if @page.nil?
      unless @current_user.logged?
        unprivileged
      else
        params.include?('create') ? create : new
      end
      return
    end
  end
end