class DashboardController < ApplicationController
  #prepend_before_filter :slash_check, :only => [:index]
  before_filter :can_view_dashboard_check

  def index
    if params.include? 'back'
      session[:link_back] = params['back']
      redirect_to url_for :controller => 'dashboard'
      return
    end
    session[:last_visit] = @current_user.last_dashboard_visit if session[:last_visit].nil?
    session[:toggle_text] = t(:show_older) if session[:toggle_text].nil?
    session[:toggle_text] == t(:show_older) ? all = false : all = true
    @news = get_news(all)
    @current_user.last_dashboard_visit = DateTime.now
    @current_user.save
    render :action => :dashboard
  end

  def toggle_news
    session[:toggle_text] == t(:show_older) ? begin
      session[:toggle_text] = t(:show_latest)
      all = true
    end : begin
      session[:toggle_text] = t(:show_older)
      all = false
    end
    @news = get_news(all)
    respond_to do |format|
      format.js do
        render :update do |page|
          #page.replace_html 'news_content', :partial => 'dashboard/news'
          page. redirect_to url_for :controller => 'dashboard'
        end
      end
      format.html { redirect_to url_for :controller => 'dashboard' }
    end
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

  def get_news(all = false)
    news = Array.new
    change = Hash.new
    for favorite in @current_user.favorite_pages
      index = 0
      favorite.page_parts_revisions.each do |revision|
        if (!revision.is_newer?(session[:last_visit]) && !all) || (index > 10 && all) 
          break
        end
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
    news = reorder_news(news)
    news.paginate(:page => params[:page], :per_page => 3)
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

  def reorder_news(news)
    ret_news = Array.new
    nested = nil
    previous = -1
    index = 0
    nested_counter = 0
    succ = 1
    for record in news
      if previous >= 0 && !news[previous].nil? && (record['who'].eql?(news[previous]['who']) && record['page_id'].eql?(news[previous]['page_id']))
        nested[nested_counter] = record.clone
        nested_counter += 1
      else
        if !news[succ].nil? && (record['who'].eql?(news[succ]['who']) && record['page_id'].eql?(news[succ]['page_id']))
          ret_news[index] = record.clone
          nested = Array.new
          nested_counter = 0
          ret_news[index]['nested'] = nested
          index += 1
        else
          ret_news[index] = record.clone
          ret_news[index]['nested'] = nil
          index += 1
        end
      end
      previous += 1
      succ += 1
    end
    ret_news
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