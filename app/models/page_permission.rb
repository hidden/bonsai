class PagePermission < ActiveRecord::Base
  belongs_to :page
  belongs_to :group

  has_many :group_permissions, :primary_key => :group_id, :foreign_key => :group_id

  def self.exists_by_user_and_page user, page, type
    permission = PagePermission.find(:first, :joins => "JOIN groups ON groups.id = page_permissions.group_id JOIN group_permissions ON group_permissions.group_id = groups.id", :conditions => ["group_permissions.user_id = ? AND page_permissions.#{type} = 1 AND page_permissions.page_id = ?", user.id, page.id])
    return !permission.nil?
  end
end
