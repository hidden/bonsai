class AdminController < ApplicationController
   before_filter :verify_admin_rights
   #, :only => [:index, :activate, :deactivate]

  def index

    @gridpage = params['gridpage'].nil? ? 1: (params['gridpage']).to_i
    @order = params['order'].nil? ? "" : params['order'].to_s
    @back = session['back'].nil? ? '' : session['back'].to_s
    

    #name = '' #params[]   #:add_user

    if (params.include? 'add_user')
       @users = User.paginate(:page => params[:page],
                              :conditions => "username='#{params['add_user']['usernames']}'")
    else
       @users = User.paginate(:page => params[:page],
                              :order => "#{(!params['order'].blank? and User.column_names.include? params['order']) ? params['order'] + ' ASC' : 'updated_at DESC'}")

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
      flash[:error] = t("views.admin.User")+" "+ @user.name
      flash[:error].concat(" "+ t("views.admin.was") +" "+ t("views.admin.deactivated") + '.')
      redirect_to admin_path
    end
  end

  def activate
    @user = User.find(params[:id])
    if @user.username!=@current_user.username
      @user.change_active(true)
      flash[:notice] = t("views.admin.User")+" "+ @user.name
      flash[:notice].concat(" "+ t("views.admin.was") +" "+ t("views.admin.activated") + '.')
      redirect_to admin_path
    end
  end


  def verify_admin_rights
    if !@current_user.verify_admin_right
        flash[:error] = t("views.admin.ad_account")
        redirect_to session[:link_back].blank? ? '/' : session[:link_back]
    end
  end
end