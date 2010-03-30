class AdminController < ApplicationController
   before_filter :verify_admin_rights
   #, :only => [:index, :activate, :deactivate]

  def index
    if params.include? 'back'
       session[:link_back] = params['back']
    end if

    #name = '' #params[]   #:add_user

    if (params.include? 'add_user')
       @users = User.paginate(:page => params[:page],
                              :conditions => "username='#{params['add_user']['usernames']}'")
    else
       @users = User.paginate(:page => params[:page],
                              :order => "#{(!params['order'].blank? and User.column_names.include? params['order']) ? params['order'] + ' ASC' : 'logtime DESC'}")

    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml =>  @users }
    end
  end

  def deactivate
    @user = User.find(params[:id])
    if @user.username!=@current_user.username
      @user.change_active(false)
      flash[:error] = t(:User)+" "+ @user.name
      flash[:error].concat(" "+ t(:was) +" "+ t(:deactivated) + '.')
      redirect_to "#{admin_path.gsub /\/(\d+)/,'/'}?back=#{session[:link_back].nil? ? '/' : session[:link_back]}"
    end
  end

  def activate
    @user = User.find(params[:id])
    if @user.username!=@current_user.username
      @user.change_active(true)
      flash[:notice] = t(:User)+" "+ @user.name
      flash[:notice].concat(" "+ t(:was) +" "+ t(:activated) + '.')
      redirect_to "#{admin_path.gsub /\/(\d+)/,'/'}?back=#{session[:link_back].nil? ? '/' : session[:link_back]}"
    end
  end

  def verify_admin_rights
    if !session[:admin]
    # read id of admin group
    #group_id = APP_CONFIG['administrators'].nil? ? nil:APP_CONFIG['administrators']['admin_group']
    # control user
    #if @current_user.logged? and !group_id.nil?
    #  group=GroupPermission.find_by_sql("SELECT * FROM group_permissions g
    #                                        WHERE g.id = '#{group_id}'
    #                                        AND g.user_id = '#{@current_user.id}'
    #                                        AND (g.can_view = 1 or g.can_edit = 1)")
    #  if group.nil?
    #    flash[:error] = t(:ad_account)
    #    redirect_to session[:link_back].blank? ? '/' : session[:link_back]
    #  end
    #else
        flash[:error] = t(:ad_account)
        redirect_to session[:link_back].blank? ? '/' : session[:link_back]
    end
  end
end