class PagePartRevision < ActiveRecord::Base
  belongs_to :page_part
  belongs_to :user
end
