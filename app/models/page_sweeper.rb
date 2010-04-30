class PageSweeper < ActionController::Caching::Sweeper
  observe Page

  def after_create(record)

  end
  def after_update(record)
    remove_pages_from_cache
  end
  def after_destroy(record)

  end

  private
  
  def remove_pages_from_cache
    pages = Page.all(:select => "id", :conditions => ["lft >= ? AND rgt <= ?",  self.lft,  self.rgt])
    pages.each do |page|
      expire_fragment(page.id)
    end
  end
end