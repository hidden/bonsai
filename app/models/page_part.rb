class PagePart < ActiveRecord::Base
  belongs_to :page
  has_many :page_part_revisions, :order => 'created_at DESC', :dependent => :destroy
  has_many :page_part_locks
  belongs_to :current_page_part_revision, :class_name => 'PagePartRevision'

  validates_presence_of :name

  def delete(part_id)
    self.delete_all(["id = ?", part_id])
  end
end
