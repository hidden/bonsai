class PagePermission < ActiveRecord::Base
  belongs_to :page
  belongs_to :group

  def after_initialize
    self.can_view = false
    self.can_edit = false
    self.can_manage = false
  end
end
