class DashboardController < ApplicationController
  #prepend_before_filter :slash_check, :only => [:index]
  before_filter :can_view_dashboard_check

  def index
    if params.include? 'back'
      session[:link_back] = params['back']
      redirect_to url_for :controller => 'dashboard'
      return
    end
    @news = get_news
    render :action => :dashboard
  end

  def remove_favorite
    @current_user.favorite_pages.delete(Page.find_by_id(params[:id]))

    respond_to do |format|
      format.js{
        render :update do |page|
          page.reload
        end
      }
      format.html{
        redirect_to url_for :controller => 'dashboard'
      }
    end
  end

  private
  def slash_check
    link = request.env['PATH_INFO']
    unless link.ends_with?('/')
      redirect_to link + '/'
      return
    end
  end

  def get_news
    news = Array.new
    change = Hash.new
    for favorite in @current_user.favorite_pages
      index = 0
      favorite.page_parts_revisions[0..9].each do |revision|
        change['when'] = revision.created_at
        change['who'] = revision.user.username
        change['what'] = revision.page_part.name
        change['revision'] = index.to_s()
        change['page_id'] = favorite.id
        push_sorted(news, change.clone)
        #news = news[0..9]
        index += 1
      end
    end
    news
  end

  def push_sorted(news, rec)
    index = 0
    news.each do |record|
      if rec['when'] > record['when']
        news.insert(index, rec)
        return
      end
      index += 1
    end
    news.push(rec)
  end

  def can_view_dashboard_check
    unless @current_user.logged? then
      unprivileged
    end
  end

  def unprivileged
    @hide_view_in_toolbar = true
    render :action => 'unprivileged'
  end

  def bad_request
    @hide_view_in_toolbar = true
    render :action => 'bad_request'
  end

end