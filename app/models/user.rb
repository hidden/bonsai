class User < ActiveRecord::Base
  has_many :group_permissions, :dependent => :destroy
  has_many :groups, :through => :group_permissions

  has_many :visible_groups, :through => :group_permissions, :class_name => 'Group', :source => :group, :conditions => ['group_permissions.can_view = ?', true]

  after_create { |user| Group.create(:name => user.username).add_viewer(user) }
  after_destroy { |user| Group.find_by_name(user.username).destroy }

  def full_name
    "#{name} (#{username})"
  end

  def can_edit_group? group
    GroupPermission.exists?(:group_id => group, :user_id => self, :can_edit => true)
  end

  def can_view_page? page
    return true
  end

  def can_edit_page? page
    true
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
    false
  end

  def can_edit_page?
    false
  end
end