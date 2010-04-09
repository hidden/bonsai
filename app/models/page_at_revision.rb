class PageAtRevision < Page
  attr_accessor :revision_date

  def resolve_part part_name
    condition =  "(? BETWEEN pages.lft AND pages.rgt)"
    condition << " AND page_parts.name = ? AND page_part_revisions.was_deleted = ?"
    condition << " AND created_at <= ?"
    latest_part_revision = PagePartRevision.first(:joins => {:page_part => :page}, :conditions => [condition, self.lft, part_name, false, self.revision_date], :order => "pages.lft DESC, page_part_revisions.id DESC")
    latest_part_revision.nil? ? nil : latest_part_revision.body
  end
end

