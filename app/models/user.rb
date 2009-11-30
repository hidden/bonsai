class User < ActiveRecord::Base
  has_many :group_permissions, :dependent => :destroy
  has_many :groups, :through => :group_permissions

  has_many :visible_groups, :through => :group_permissions, :class_name => 'Group', :source => :group, :conditions => ['group_permissions.can_view = ?', true]

  has_many :favorites
  has_many :favorite_pages, :through => :favorites, :class_name => 'Page', :source => :page

  before_create { |user| user.generate_unique_token }
  after_create { |user| Group.create(:name => user.username).add_as_non_viewer(user) }
  after_destroy { |user| user.private_group.destroy }

  def full_name
    "#{username} (#{name})"
  end

  def generate_unique_token
    self.token = ActiveSupport::SecureRandom.hex(16)
    generate_unique_token unless User.find_by_token(self.token).nil?
  end

  def private_group
    Group.find_by_name(self.username)
  end

  def can_edit_group? group
    group.is_editable? ? true : GroupPermission.exists?(:group_id => group, :user_id => self, :can_edit => true)
  end

  def can_view_page? page
    return true if page.is_public?
    return !PagePermission.first(:joins => [:page, :group_permissions], :conditions => ["(? BETWEEN pages.lft AND pages.rgt) AND group_permissions.user_id = ? AND (page_permissions.can_view = ? OR page_permissions.can_edit = ? OR page_permissions.can_manage = ?)", page.lft, self.id, true, true, true]).nil?
  end

  def can_edit_page? page
    return true if page.is_editable?
    return !PagePermission.first(:joins => [:page, :group_permissions], :conditions => ["(? BETWEEN pages.lft AND pages.rgt) AND group_permissions.user_id = ? AND (page_permissions.can_edit = ? OR page_permissions.can_manage = ?)", page.lft, self.id, true, true]).nil?
  end

  def can_manage_page? page
    return !PagePermission.first(:joins => [:page, :group_permissions], :conditions => ["(? BETWEEN pages.lft AND pages.rgt) AND group_permissions.user_id = ? AND page_permissions.can_manage = ?", page.lft, self.id, true]).nil?
  end

  def logged?
    true
  end
end

class AnonymousUser
  def logged?
    false
  end

  def can_view_page? page
    return page.is_public?
  end

  def can_edit_page? page
    false
  end

  def can_manage_page? page
    false
  end

  def token
    nil
  end
end
