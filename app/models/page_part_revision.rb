class PagePartRevision < ActiveRecord::Base
  belongs_to :page_part
  belongs_to :user

  def self.revision_conflict?(created_at, revision_id)
    count = self.count(:conditions => ["created_at > ? and page_part_id = ?", created_at, revision_id.id])
    return (count>0)
  end
end
