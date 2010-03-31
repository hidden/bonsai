class GroupPermissionsController < ApplicationController
  before_filter :verify_editor_permission

  def verify_editor_permission
    #@current_user = session[:user]
    #permission = GroupPermission.find_by_id(params[:id])
    redirect_to groups_path unless @current_user.can_edit_group? Group.find_by_id(params[:group_id])
  end

  def create
    users = User.find_all_by_username(params[:add_user][:usernames].split(/[ ]*, */))
    if users.empty?
      flash[:notice] = t(:user_not_found)
    else
      for user in users do
        Group.find(params[:group_id]).add_viewer user if params[:add_user][:type] == '1'
        Group.find(params[:group_id]).add_editor user if params[:add_user][:type] == '2'
        gh = GroupPermissionsHistory.new(:user_id => user.id, :group_id => params[:group_id], :editor_id => @current_user.id, :role => params[:add_user][:type], :action => 1)
        gh.save
      end
    end
    redirect_to edit_group_path(params[:group_id])
  end

  def switch_view
    permission = GroupPermission.find_by_id(params[:id])
   unless permission.user == @current_user
      if permission.can_view?
        gh = GroupPermissionsHistory.new(:user_id => permission.user_id, :group_id => permission.group_id, :editor_id => @current_user.id, :role => 1, :action => 2)
      else
        gh = GroupPermissionsHistory.new(:user_id => permission.user_id, :group_id => permission.group_id, :editor_id => @current_user.id, :role => 1, :action => 1)
      end
      permission.switch_view
      gh.save
    end
    permission.save
    redirect_to edit_group_path(params[:group_id])
  end

  def switch_edit
    permission = GroupPermission.find_by_id(params[:id])
    unless permission.user == @current_user
      if permission.can_edit?
        gh = GroupPermissionsHistory.new(:user_id => permission.user_id, :group_id => permission.group_id, :editor_id => @current_user.id, :role => 2, :action => 2)
      else
        gh = GroupPermissionsHistory.new(:user_id => permission.user_id, :group_id => permission.group_id, :editor_id => @current_user.id, :role => 2, :action => 1)
      end
      permission.switch_edit
      gh.save
    end
    permission.save
    redirect_to edit_group_path(params[:group_id])
  end

  def destroy
    permission = GroupPermission.find_by_id(params[:id])
    unless permission.user == @current_user
      if permission.can_edit?
        gh = GroupPermissionsHistory.new(:user_id => permission.user_id, :group_id => permission.group_id, :editor_id => @current_user.id, :role => 2, :action => 2)
        gh.save
      end
      if permission.can_view?
        gh = GroupPermissionsHistory.new(:user_id => permission.user_id, :group_id => permission.group_id, :editor_id => @current_user.id, :role => 1, :action => 2)
        gh.save
      end
      permission.destroy
    end
    redirect_to edit_group_path(params[:group_id])
  end
end
