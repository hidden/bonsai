class PagePermissionsHistory < ActiveRecord::Base
  belongs_to :page
  belongs_to :group
  belongs_to :user
end
