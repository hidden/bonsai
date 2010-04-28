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
    pages = Page.all(:select => "id", :conditions => ["lft >= ? AND rgt <= ?",  record.lft,  record.rgt])
    pages.each do |page|
      ActionController::Base.new.expire_fragment(page.id)
    end
  end
end