class GroupPermissionsController < ApplicationController
  before_filter :verify_editor_permission

  def verify_editor_permission
    @current_user = session[:user]
    permission = GroupPermission.find_by_id(params[:id])
    redirect_to groups_path unless @current_user.can_edit_group? Group.find_by_id(params[:group_id])
  end

  def create
    user = User.find_by_username(params[:add_username])
    if user.nil?
      flash[:notice] = 'Username not found!'
    else
      Group.find(params[:group_id]).add_viewer user if params[:add_permission][:type] == 'viewer'
      Group.find(params[:group_id]).add_editor user if params[:add_permission][:type] == 'editor'
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
