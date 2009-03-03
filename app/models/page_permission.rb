class PagePermission < ActiveRecord::Base
  belongs_to :page
  belongs_to :group

  def after_initialize
    self.can_view = false
    self.can_edit = false
    self.can_manage = false
  end

  def self.exists_viewable_by_user_and_page user, page
    permission = PagePermission.find(:first, :joins => "JOIN groups ON groups.id = page_permissions.group_id JOIN group_permissions ON group_permissions.group_id = groups.id", :conditions => ["group_permissions.user_id = ? AND page_permissions.can_view = 1 AND page_permissions.page_id = ?", user.id, page.id])
    return !permission.nil?
  end
end
