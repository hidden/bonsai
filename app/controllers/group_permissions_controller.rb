class GroupPermissionsController < ApplicationController
  before_filter :verify_editor_permission

  def verify_editor_permission
    @current_user = session[:user]
    redirect_to groups_path unless @current_user.can_edit_group? Group.find_by_id(params[:group_id])
  end

  def create
    user = User.find_by_username(params[:add_username])
    if user.nil?
      flash[:notice] = 'Username not found!'
    else
      GroupPermission.create(:group_id => params[:group_id], :user_id => user.id, :permission => params[:add_permission][:type])
    end
    redirect_to edit_group_path(params[:group_id])
  end

  def destroy
    GroupPermission.find_by_id(params[:id]).destroy
    redirect_to edit_group_path(params[:group_id])
  end
end
