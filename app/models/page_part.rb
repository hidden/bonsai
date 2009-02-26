class PagePart < ActiveRecord::Base
  belongs_to :page
  has_many :page_part_revisions, :dependent => :destroy
  belongs_to :current_page_part_revision, :class_name => 'PagePartRevision'
end
