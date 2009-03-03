class PagePartRevision < ActiveRecord::Base
  validates_presence_of :summary
  
  belongs_to :page_part
  belongs_to :user
end
