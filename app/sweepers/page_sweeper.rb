class PageSweeper < ActionController::Caching::Sweeper
  observe Page

  def after_create(record)
  end
  def after_update(record)
    expire_cache(record)
  end
  def after_destroy(record)
  end

  private
  def expire_cache(record)
    #expire_page :controller => 'page', :action => 'remove_pages_from_cache'
    pages = Page.all(:select => "id", :conditions => ["lft >= ? AND rgt <= ?",  record.lft,  record.rgt])
    pages.each do |page|
      expire_fragment(page.id)
    end
  end
end