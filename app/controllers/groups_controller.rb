class GroupsController < ApplicationController
  before_filter :verify_editor_permission, :only => [:remove, :add]
  before_filter :verify_editor_permission_by_id, :only => [:destroy, :edit, :update, :switch_public, :switch_editable]

  def verify_editor_permission_by_id
    redirect_to groups_path unless @current_user.can_edit_group? Group.find_by_id(params[:id])
  end

  def verify_editor_permission
    redirect_to groups_path unless @current_user.can_edit_group? Group.find_by_id(params[:group_id])
  end

  def permissions_history
    @group = Group.find(params[:id])
    #@permissions_history = GroupPermissionsHistory.find_all_by_group_id(@group.id) #:joins => 'JOIN users e ON e.id = editor_id', :order => 'created_at DESC')
    #stmnt =  "SELECT p.id, p.user_id, p.editor_id, p.group_id, p.role, p.action, u.username, u2.username as editor FROM group_permissions_histories p JOIN users u ON u.id = user_id  JOIN users u2 ON u2.id = p.editor_id WHERE group_id = ???"
    #stmnt["???"] = @group.id.to_s()
    #@permissions_history = GroupPermissionsHistory.find_by_sql(stmnt)
    @permissions_history = GroupPermissionsHistory.paginate( :all,:conditions => "group_id='#{@group.id}'", :include => [:user, :editor], :per_page => 20, :page => params[:page], :order => 'created_at DESC')
    @no_toolbar = true
    #return render('groups/permissions_history')
    respond_to do |format|
      format.html # index.html.erb
      format.xml do
        render 'groups/permissions_history'
      end
    end
  end

  def autocomplete_for_user
    @infix = params[:infix]
    @users = User.all(:conditions => ["name LIKE :infix OR username LIKE :infix", {:infix => "%#{@infix}%"}], :limit => 10, :order => 'username')
    render :partial => 'autocomplete_users'
  end
  
  def autocomplete_for_groups
    @infix = params[:infix]
    groups = Group.all(:joins => {:group_permissions => :user}, :conditions => ["groups.name LIKE :infix OR users.name LIKE :infix OR users.username LIKE :infix", {:infix => "%#{@infix}%"}], :group => :id, :limit => 10)
    @auto_groups = groups.select do |group|
      group.is_public? or group.users.include?(@current_user)      
    end
    render :partial => 'autocomplete_groups'
   end  

  # GET /groups
  # GET /groups.xml
  def index
    if params.include? 'back'
      session[:link_back] = params['back']
      redirect_to groups_path
      return
    end
    if @current_user.instance_of?(AnonymousUser)
      return render(:template => 'page/unprivileged')
    end
    #@groups = @current_user.visible_groups + Group.groups_visible_for_all
    #uniq! removes duplicate elements from self but returns nil if no changes are made (that is, no duplicates are found).
    #@groups = @groups.uniq!.nil? ? (@current_user.visible_groups + Group.groups_visible_for_all):@groups

    stmnt =  "SELECT group_permissions.group_id as id, groups.name  FROM group_permissions JOIN groups on group_permissions.group_id = groups.id LEFT JOIN users on users.username = groups.name where user_id = ??? and users.id is null"
    stmnt["???"] = @current_user.id.to_s()
    visible_for_user = Group.find_by_sql(stmnt)
    public =  Group.find_by_sql("SELECT group_permissions.group_id as id, groups.name  FROM group_permissions JOIN groups on group_permissions.group_id = groups.id LEFT JOIN users ON users.username = groups.name WHERE ((group_permissions.can_view = 0 OR group_permissions.can_view = NULL) AND users.id is null) ")
    @groups = visible_for_user + public
    @groups = @groups.uniq!.nil? ? (visible_for_user + public):@groups

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.xml
  def create
    #@current_user = session[:user]
    @group = Group.new(params[:group])
    respond_to do |format|
      if @group.save
        @group.add_editor @current_user
        gh = GroupPermissionsHistory.new(:user_id => @current_user.id, :group_id => @group.id, :editor_id => @current_user.id, :role => 2, :action => 1)
        gh.save
        flash[:notice] = t(:group_created)
        format.html { redirect_to edit_group_path(@group) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = t(:group_updated)
        format.html { redirect_to groups_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def add
    user
  end

  def remove
    GroupPermission.find_by_group_id_and_user_id(params[:group_id], params[:id]).destroy
    redirect_to edit_group_path(params[:group_id])
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    if params[:id].to_i != APP_CONFIG['administrators']['admin_group'].to_i
      @group = Group.find(params[:id])
      unless @group.name == @current_user.username
        @group.destroy
      end
    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
    else
      flash[:notice] = t(:err_destroy_group)
      redirect_to groups_path
    end
  end

  def switch_public
    @group = Group.find(params[:id])
    if (@group.is_public?)
      gh = GroupPermissionsHistory.new(:user_id => 0, :group_id => @group.id, :editor_id => @current_user.id, :role => 1, :action => 2)
    else
      gh = GroupPermissionsHistory.new(:user_id => 0, :group_id => @group.id, :editor_id => @current_user.id, :role => 1, :action => 1)
    end
    was_public = @group.is_public?
    @group.group_permissions.each do |permission|
      permission.can_view = was_public
      permission.can_edit = was_public if was_public
      permission.save
    end
    gh.save
    redirect_to edit_group_path(params[:id])
  end

  def switch_editable
    @group = Group.find(params[:id])
    if (@group.is_editable?)
      gh = GroupPermissionsHistory.new(:user_id => 0, :group_id => @group.id, :editor_id => @current_user.id, :role => 2, :action => 2)
    else
      gh = GroupPermissionsHistory.new(:user_id => 0, :group_id => @group.id, :editor_id => @current_user.id, :role => 2, :action => 1)
    end
    was_editable = @group.is_editable?
    @group.group_permissions.each do |permission|
      permission.can_view = was_editable if !was_editable
      permission.can_edit = was_editable
      permission.save
    end
    gh.save
    redirect_to edit_group_path(params[:id])
  end
end
