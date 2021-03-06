class PageController < ApplicationController
  cache_sweeper :page_sweeper, :only => [:update]

  before_filter :load_page, :except => [:add_lock, :update_lock, :search, :system_page]
  before_filter :can_manage_page_check, :only => [:set_permissions, :remove_permission, :switch_public, :switch_editable, :update_permissions]
  before_filter :can_edit_page_check, :only => [:add, :edit, :update, :upload, :undo, :new_part, :files, :render_files, :revert_file]
  before_filter :check_file, :only => [:view]
  before_filter :slash_check, :only => [:view]
  before_filter :is_blank_page, :only => [:view]
  before_filter :can_view_page_check, :only => [:view, :history, :revision, :diff, :toggle_favorite]
  before_filter :remove_back_link
 # before_filter :control_highlight, :only => [:view]


  around_filter :rss_view_check, :only => [:rss, :rss_tree]

  def search
    @query = params[:search_query]
    @search_results = Page.search(
      @query,
      :conditions => {:page_id => @current_user.find_all_accessible_pages.collect(&:id)},
      :include => {:page_parts => :current_page_part_revision},
      :page => params[:page],
      :excerpts => true,
      :per_page => APP_CONFIG['fulltext_page_results']
    )
  end

  def permissions_history
    @permissions_history = PagePermissionsHistory.paginate( :all, :conditions => {:page_id => @page.id}, :include => [:user, :group], :per_page => 20, :page => params[:page], :order => 'id DESC')
    @history_toolbar = true
  end

  def view
    control_highlight(@page.ordered_page_parts)
    @hide_view_in_toolbar = true
    layout = @page.nil? ? 'application' : @page.resolve_layout
    @stylesheet = @page.resolve_layout
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

  def revert_file
    file = UploadedFile.find_by_id(params[:file])
    file.current_file_version_id = params[:version]
    file.save
    redirect_to file_history_page_path(@page, file.filename)
  end

  def diff
    page = PageAtRevision.find_by_path(@path)
    number_of_revisions = @page.page_parts_revisions.length

    first_revision = number_of_revisions - params[:first_revision].to_i
    second_revision = number_of_revisions - params[:second_revision].to_i
    if (first_revision < second_revision)
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
    @stylesheet = @page.resolve_layout
    render :action => 'show_revision', :layout => layout
  end

  def undo
    @page_revision = @page.page_parts_revisions[params[:revision].to_i]
    @page_part = @page_revision.page_part
    @undo = true
    edit
  end

  def switch_public
    was_public = @page.is_public?
    (@page.is_public?) ? action = "2" : action = "1"
    if (@page.parent.nil? || @page.parent.is_public?)
      @page.page_permissions.each do |permission|
        permission.can_view = was_public
        #permission.can_edit = was_public if was_public
        #TODO: if the @page has some public descendants, we should spread the switch to them as well
        permission.save
      end
      ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => 0, :role => 1, :action => action)
      ph.save
    end
  end

  def switch_editable
    was_editable = @page.is_editable?
    (@page.is_editable?) ? action = "2" : action = "1"
    if (@page.parent.nil? || @page.parent.is_public?)
      @page.page_permissions.each do |permission|
        permission.can_view = was_editable if !was_editable
        permission.can_edit = was_editable
        #TODO: if the @page has some public descendants, we should spread the switch to them as well
        permission.save
      end
      ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => 0, :role => 2, :action => action)
      ph.save
    end
  end

  def remove_permission
    page_permission = @page.page_permissions[params[:index].to_i]
    managers = get_num_of_managers
    if ((page_permission.can_manage? && managers >= 2) || !page_permission.can_manage?)
      if (page_permission.can_manage?)
        ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 3, :action => 2)
        ph.save
      end
      if (page_permission.can_edit? || @page.is_editable?)
        ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 2, :action => 2)
        ph.save
      end
      if (page_permission.can_view? || @page.is_public?)
        ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 1, :action => 2)
        ph.save
      end
      page_permission.destroy
    else
      flash[:error] = t("controller.notices.manager_error")
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def update_permissions
    save_permissions
    @page.reload # reload permission
    if flash[:error].nil?
      @notice = t("views.page.permissions_updated")
    else
      @error = t("controller.notices.manager_error")
      flash.discard
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
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
    if File.exist?(file_version.filename_with_path_and_version)
      send_file(file_version.filename_with_path_and_version, opts)
    else
      render :action => :file_deleted
    end
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
      @parent_layout = 'default'
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

    layout_select

    if (!@parent_id.nil? && !(@current_user.can_edit_page? Page.find_by_id(@parent_id)))
      unprivileged
    else
      @sid = @path.empty? ? nil : @path.last
      render :action => 'new'
    end
  end

  def create
    if params.include?('Preview')
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
      page = Page.new(:title => params[:title], :sid => sid, :layout => layout, :ordering => params[:ordering])
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
        flash[:notice] = t("controller.notices.page_created")
        page_part.current_page_part_revision = first_revision
        page_part.save!
      end
      redirect_to page_path(page)
    end
  end

  def rss
    @recent_revisions = @page.get_page_revisions
    render :layout => false
  end

  def rss_tree
   @recent_revisions = @page.get_page_subtree_revisions(@current_user)
    render :layout => false
  end

  def add
     if (params.include? 'add_page')
       path =  (params[:path].blank? ? '' : (params[:path].to_s + '/')) + params['add_page']['new_page']
       p = control_page (path)
       #flash[:notice] = path
         if (!p.blank?)
          flash[:error] = t("views.page.page_exist")
          render :action => :add
         else
           flash.discard
           redirect_to ('/' + path)
         end
     else
         render :action => :add
     end
   end

   def control_page  path
    p = Page.find_by_path(path.to_a)
    return p
  end

  def edit
    @per_page = APP_CONFIG['edit_files_per_page']
    @list_len = (@page.uploaded_files.length > @per_page) ? @per_page : @page.uploaded_files.length
    
    @layout = @page.layout

    if @layout.nil?
      @parent_layout = @page.inherited_layout
    else
      @parent_layout = @page.parent_layout
    end
    
    layout_select
    render :action => :edit
  end

  def render_files
    order = params[:order].eql?('name') ? 'filename ASC' : 'current_file_version_id DESC'
    @uploaded_files = @page.uploaded_files.paginate(:page => params[:page], :per_page => params[:per_page], :order => order) #params[:per_page] sa nastavuje v edit metode ako @per_page
    @status = {'error', params[:success].empty? ? false : true, 'msg', params[:success].empty? ? t("controller.notices.file_uploaded") : params[:success]} if (params.include?('success'))
    params.delete(:success) if (params.include?('success'))
    if params.include?(:change)
      session[:sort] = session[:sort].eql?('name') ? 'date' : 'name'
      params.delete(:change)
    end
    render :partial => 'files'
  end

  def set_permissions
    addedgroups = params[:add_group].split(/[ ]*, */)
    for addedgroup in addedgroups
      groups = Group.find_all_by_name(addedgroup)
      unless groups.any? then
        #create user group
        tmp_user = User.create(:username => addedgroup, :name => "#{addedgroup} (tmp)")
        groups = [tmp_user.user_group]
      end
      for group in groups
        users = group.users
        if (group.is_public? || users.include?(@current_user))
          @page.add_viewer group if params[:group_role][:type] == "1"
          @page.add_editor group if params[:group_role][:type] == "2"
          @page.add_manager group if params[:group_role][:type] == "3"
          ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => group.id, :role => params[:group_role][:type], :action => 1)
          ph.save
        end
      end
    end
  end

  def remove_page_part
    begin
      page_part = PagePart.find(params[:part_id])
      current_revision = page_part.current_page_part_revision
      revision = page_part.page_part_revisions.create(:user => @current_user, :body => current_revision.body, :summary => current_revision.summary, :was_deleted => true)
      page_part.current_page_part_revision = revision
      page_part.save
    rescue
      logger.error "Deletion of page part #{part_id} failed"
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def save_edit
    if params.include?('Preview')
      generate_preview
      return
    end
    if params[:parts].nil?
      unprivileged
      return
    end
    @error_flash_msg = ""
    @notice_flash_msg = ""

    # TODO refactor
#    unless params[:file_version].blank? or params[:file_version][:uploaded_data].blank?
#      tmp_file = params[:file_version][:uploaded_data]
#      filename = File.basename(tmp_file.original_filename)
#      do_upload(tmp_file, filename)
#    end

    if not (params[:new_page_part_name].empty? and params[:new_page_part_text].empty?)
      new_part
    end

    update

    flash[:error] = @error_flash_msg unless @error_flash_msg.empty?
    flash[:notice] = @notice_flash_msg unless @notice_flash_msg.empty? or not @error_flash_msg.empty?
    redirect_to page_path(@page)
  end

  def update
    @num_of_changed_page_parts = 0
    @page.title = params[:title]
    if @current_user.can_manage_page? @page
      @page.layout = params[:layout].empty? ? nil : params[:layout]
      @page.ordering = params[:ordering]
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
            edit
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
      error = t("controller.notices.page_updated_with_new_revisions")
    else
      notice = t("controller.notices.page_updated")
    end

    if params[:non_redirect].nil?

      flash[:notice] = notice if notice
      redirect_to page_path(@page)
    else
      #flash[:error] = error if error
      @error_flash_msg = error if error
      @notice_flash_msg = @notice_flash_msg + notice.to_s + "\r\n"
      #TODO WTF?
    end
  end


  def new_part
    page_part = @page.page_parts.find_or_create_by_name(:name => params[:new_page_part_name], :current_page_part_revision_id => 0)
    unless page_part.valid?
      error_message = ""
      page_part.errors.each_full { |msg| error_message << msg }
      if params[:non_redirect].nil?
        flash[:error] = error_message
        edit
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
      flash[:notice] = t("controller.notices.page_part_added")
      redirect_to edit_page_path(@page)
    else
      @notice_flash_msg += t("controller.notices.page_part_added") + "\r\n"
    end
  end

  def upload
    @notice_flash_msg = "" if @notice_flash_msg.blank?
    @error_flash_msg = "" if @error_flash_msg.blank?
    unless params[:file_version].blank? or params[:file_version][:uploaded_data].blank?
      tmp_file = params[:file_version][:uploaded_data]
      filename = File.basename(tmp_file.original_filename)
      target_filename = params[:uploaded_file_filename]
      if !target_filename.blank? and (File.extname(filename) != File.extname(target_filename))
        @error_flash_msg += t("controller.notices.file_not_match") + "\r\n"
      else
        filename = target_filename unless target_filename.blank?
        do_upload(tmp_file, filename)
      end
    else
      @error_flash_msg += t("controller.notices.no_files_selected") + "\r\n"
    end
    unless params.include?('redirect')
      flash[:error] = @error_flash_msg unless @error_flash_msg.empty?
      flash[:notice] = @notice_flash_msg unless @notice_flash_msg.empty? or not @error_flash_msg.empty?
    end
    redirect_to params.include?('redirect') ? render_files_path(@page, params[:per_page], @upscale, @error_flash_msg) : list_files_path(@page)
  end

  def do_upload(tmp_file, filename)
    unless @page.children.find_by_sid(filename).nil?
      @error_flash_msg += t("controller.notices.same_as_page") + "\r\n"
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
    if (file.save!)
      @notice_flash_msg += t("controller.notices.file_uploaded") + "\r\n"
      if (version.version == 1)
        @upscale = true
      end
    else
      file.errors.each_full { |msg| @error_flash_msg << msg }
    end
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
      format.html { redirect_to page_path(@page) }
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

  def show_layout_helper
    #get params
    layout = params["layout"]
    @parent_layout = params["parent_layout"]

     #layout
    @layout = layout

    #inherited layout
    @inherited = false

    if @parent_layout.blank?
      @parent_layout = @page.inherited_layout
    end

    if layout.blank?
      layout =  @parent_layout
    end



    if layout == @parent_layout
      @inherited=true
    end

    #stylesheet
    if layout != 'default'
      @stylesheet = layout + '.css'
    end

    params = get_layout_parameters("vendor/layouts/"+layout)
    @layout_name = params[1]
    @layout_description = params[0]
    @layout_params = params[2]

  end

  def maruku_help
    render :layout => false
  end

  private

  def remove_back_link
     session[:link_back] = nil
  end

  def generate_preview
    parent = nil
    unless params[:parent_id].blank?
      parent = Page.find_by_id(params[:parent_id])
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
        build_parts(name, body)
#        page_part = @page.page_parts.build(:name => name, :current_page_part_revision_id => 0)
#        first_revision = page_part.page_part_revisions.build(:user => @current_user, :body => body, :was_deleted => false)
#        page_part.current_page_part_revision = first_revision
      end : begin
        build_parts("body", params[:body])
#        page_part = @page.page_parts.build(:name => "body", :current_page_part_revision_id => 0)
#        first_revision = page_part.page_part_revisions.build(:user => @current_user, :body => params[:body], :was_deleted => false)
#        page_part.current_page_part_revision = first_revision
      end

      unless (params[:new_page_part_name].nil? || params[:new_page_part_name].empty?)
        build_parts(params[:new_page_part_name], params[:new_page_part_text])
#        page_part = @page.page_parts.build(:name => params[:new_page_part_name], :current_page_part_revision_id => 0)
#        first_revision = page_part.page_part_revisions.build(:user => @current_user, :body => params[:new_page_part_text], :was_deleted => false)
#        page_part.current_page_part_revision = first_revision
      end
      @page.page_parts.sort! {|x, y| x.name <=> y.name } if params[:ordering]==1
      control_highlight(@page.page_parts)
      @preview_toolbar = true
      @stylesheet = @page.resolve_layout
      render :action => :preview, :layout => layout
    end
  end

  def build_parts(name, body)
    page_part = @page.page_parts.build(:name => name, :current_page_part_revision_id => 0)
    first_revision = page_part.page_part_revisions.build(:user => @current_user, :body => body, :was_deleted => false)
    page_part.current_page_part_revision = first_revision
  end

  def load_page
    @path = params[:path]
    @page = Page.find_by_path(@path)
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
    unless link.ends_with?('/') or link.include?(';')
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

  def save_permissions   
    set_global_permissions

    set_dropdown_permissions

    #add group permission from autocomplete
    if not params[:add_group].nil?
      set_permissions
    end
  end

  def set_global_permissions
    #set page public or editable
    if params[:everyone_select] == "1"
      if !@page.is_public?
        switch_public
      else
        if @page.is_editable?
          switch_editable
        end
      end
    else
      if params[:everyone_select] == "2" && !@page.is_editable?
        switch_editable
      else
        if params[:everyone_select] == "-"
          if @page.is_editable?
            switch_editable
          end
          if  @page.is_public?
            switch_public
          end
        end
      end
    end
  end

  def set_dropdown_permissions
    @managers = get_num_of_managers
    @page.page_permissions.each do |permission|
      selectbox_value = params[permission.group.name + "_select"]
      if not selectbox_value.nil?
        opravnenie = get_permission permission

        if (selectbox_value == '1')
          if opravnenie == 2
            switch_editor permission
          end
          if opravnenie == 3
            if @managers >= 2
            switch_manager permission
            switch_editor permission
            else
              flash[:error] = t("controller.notices.manager_error")
            end
          end
        else if (selectbox_value == '2')
          if opravnenie == 1
            switch_editor permission
          end
          if opravnenie == 3
            switch_manager permission
          end
        else if (selectbox_value == '3')
          if opravnenie == 1 || opravnenie == 2
            switch_manager permission
          end
        end
        end
        end
      end
    end
  end

  def switch_editor page_permission
    if page_permission.can_edit?
      @page.remove_editor(page_permission.group)
      action = "2"
    else
      @page.add_editor(page_permission.group)
      action = "1"
    end
    page_permission.save
    ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 2, :action => action)
    ph.save
  end

  def switch_manager page_permission
    if page_permission.can_manage?
      if @managers >= 2
        @page.remove_manager(page_permission.group)
        @managers = @managers - 1
        ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 3, :action => 2)
        ph.save
      else
        flash[:error] = t("controller.notices.manager_error")
      end
    else
      @page.add_manager(page_permission.group)
      ph = PagePermissionsHistory.new(:page_id => @page.id, :user_id => @current_user.id, :group_id => page_permission.group.id, :role => 3, :action => 1)
      ph.save
    end
    page_permission.save
  end

  def get_permission permission
    opravnenie = 0;
    (permission.can_view || @page.is_public?) ? opravnenie = 1 : opravnenie = opravnenie
    (permission.can_edit || @page.is_editable?) ? opravnenie = 2 : opravnenie = opravnenie
    (permission.can_manage) ? opravnenie = 3 : opravnenie = opravnenie
    return opravnenie
  end

  def get_num_of_managers
    managers = PagePermission.find_all_by_page_id(@page.id, :conditions => "can_manage = 1")
    return managers.length
  end

  def get_layout_definitions
    directories =  Array.new
    Dir.glob("vendor/layouts/*") do |directory|
      if File::directory? directory
        if File.exist? ("#{directory}/definition.yml")
          directories.push directory
        end
      end
    end
    return directories
  end

  def get_layout_parameters(file)
    layout = YAML.load_file("#{file}/definition.yml")
    unless layout.nil?
      layout_value = file[(file.rindex("/")+1)..-1]
      parameters =[ layout_value, layout['name'], layout['parts'] ]
    end
    return parameters
  end

  def layout_select
    #read layout names data
    @definition = get_layout_definitions

    #basic layout settings
    if (@definition.length == 0)
       @user_layouts = [['Inherit', nil]]
    else
       @user_layouts = []
    end

    @parent_layout = @page.parent_layout unless @page.nil?

    #pokial je v edite definovany layout
    if (!@page.nil? and @layout.nil?)
       @layout = @page.layout
    end

    #ak nema stranka lyout moze dedit
    #pokial je nova stranka, selectujem na inherit
    @layout = '' if (@layout.nil? or @page.parent_layout == @layout)


    for file in @definition
    params = get_layout_parameters(file)


    if (!@parent_layout.nil? and params[0] == @parent_layout)
         option_text = 'Inherited (' + params[1] + ')'
    else
         option_text = params[1]
    end

    option_value = (params[0] == @parent_layout) ? '' : params[0]
    @user_layouts.push([option_text, option_value])
    end

   return @user_layouts;
  end

  def control_highlight pages
    @highlighter_display = false

    for part in pages
        unless part.current_page_part_revision.was_deleted
          @highlighter_display = true unless part.current_page_part_revision.body.match(/\{:[ ]{0,3}class/).nil?
        end
    end
  end
end
