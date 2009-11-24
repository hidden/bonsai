class GroupsController < ApplicationController
  before_filter :verify_editor_permission, :only => [:remove, :add]
  before_filter :verify_editor_permission_by_id, :only => [:destroy, :edit, :update, :switch_public, :switch_editable]

  def verify_editor_permission_by_id
    redirect_to groups_path unless @current_user.can_edit_group? Group.find_by_id(params[:id])
  end

  def verify_editor_permission
    redirect_to groups_path unless @current_user.can_edit_group? Group.find_by_id(params[:group_id])
  end

  def autocomplete_for_user
    @users = User.all(:conditions => ["username LIKE ?", "#{params[:prefix]}%"], :limit => 10, :order => 'username')
    render :partial => 'autocomplete_users'
  end
  
  def autocomplete_for_groups
      @groups = Group.all(:conditions => ["name LIKE ?", "#{params[:prefix]}%"], :limit => 10, :order => 'name')
      @auto_groups = @groups.clone
      for group in @groups
        users = group.users
        retVal = group.is_public?
        retValUsers = users.include?(@current_user)
        if (retVal || retValUsers)
        else
          @auto_groups.delete(group)
        end
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
    #@groups = @current_user.visible_groups + Group.groups_visible_for_all
    #uniq! removes duplicate elements from self but returns nil if no changes are made (that is, no duplicates are found).
    #@groups = @groups.uniq!.nil? ? (@current_user.visible_groups + Group.groups_visible_for_all):@groups

    stmnt =  "SELECT group_permissions.group_id as id, groups.name  FROM group_permissions JOIN groups on group_permissions.group_id = groups.id LEFT JOIN users on users.name = groups.name where user_id = ??? and users.id is null"
    stmnt["???"] = @current_user.id.to_s()
    visible_for_user = Group.find_by_sql(stmnt)
    public =  Group.find_by_sql("SELECT group_permissions.group_id as id, groups.name  FROM group_permissions JOIN groups on group_permissions.group_id = groups.id LEFT JOIN users ON users.name = groups.name WHERE ((group_permissions.can_view = 0 OR group_permissions.can_view = NULL) AND users.id is null) ")
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
    @group = Group.find(params[:id])
    unless @group.name == @current_user.username
      @group.destroy
    end
    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end

  def switch_public
    @group = Group.find(params[:id])
    was_public = @group.is_public?
    @group.group_permissions.each do |permission|
      permission.can_view = was_public
      permission.can_edit = was_public if was_public
      permission.save
    end
    redirect_to edit_group_path(params[:id])
  end

  def switch_editable
    @group = Group.find(params[:id])
    was_editable = @group.is_editable?
    @group.group_permissions.each do |permission|
      permission.can_view = was_editable if !was_editable
      permission.can_edit = was_editable
      permission.save
    end
    redirect_to edit_group_path(params[:id])
  end
end
