class GroupPermissionsController < ApplicationController
  before_filter :verify_editor_permission

  def verify_editor_permission
    @current_user = session[:user]
    permission = GroupPermission.find_by_id(params[:id])
    if permission.user == @current_user or !@current_user.can_edit_group? Group.find_by_id(params[:group_id])
      redirect_to groups_path
    end
  end

  def create
    user = User.find_by_username(params[:add_username])
    if user.nil?
      flash[:notice] = 'Username not found!'
    else
      permission = GroupPermission.find_or_initialize_by_group_id_and_user_id(params[:group_id], user.id)
      permission.can_view = true
      permission.can_edit = params[:add_permission][:type] == 'editor'
      permission.save
    end
    redirect_to edit_group_path(params[:group_id])
  end

  def switch
    permission = GroupPermission.find_by_id(params[:id])
    permission.switch unless permission.user == @current_user
    permission.save
    redirect_to edit_group_path(params[:group_id])
  end

  def destroy
    permission = GroupPermission.find_by_id(params[:id])
    permission.destroy unless permission.user == @current_user
    redirect_to edit_group_path(params[:group_id])
  end
end
