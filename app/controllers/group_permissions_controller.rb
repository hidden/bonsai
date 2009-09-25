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
      flash[:notice] = 'Username not found!'
    else
      for user in users do
        Group.find(params[:group_id]).add_viewer user if params[:add_user][:type] == 'viewer'
        Group.find(params[:group_id]).add_editor user if params[:add_user][:type] == 'editor'
      end
    end
    redirect_to edit_group_path(params[:group_id])
  end

  def switch_view
    permission = GroupPermission.find_by_id(params[:id])
    permission.switch_view unless permission.user == @current_user
    permission.save
    redirect_to edit_group_path(params[:group_id])
  end

  def switch_edit
    permission = GroupPermission.find_by_id(params[:id])
    permission.switch_edit unless permission.user == @current_user
    permission.save
    redirect_to edit_group_path(params[:group_id])
  end

  def destroy
    permission = GroupPermission.find_by_id(params[:id])
    permission.destroy unless permission.user == @current_user
    redirect_to edit_group_path(params[:group_id])
  end
end
