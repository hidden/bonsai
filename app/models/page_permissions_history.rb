class PagePermissionsHistory < ActiveRecord::Base
  belongs_to :page
  belongs_to :group
  belongs_to :user

  def is_newer?(date)
    return self.created_at >= date ? true : false unless date.nil?
    true
  end
end
