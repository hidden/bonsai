class User < ActiveRecord::Base
  has_many :group_permissions, :dependent => :destroy
  has_many :groups, :through => :group_permissions

  has_many :visible_groups, :through => :group_permissions, :class_name => 'Group', :source => :group, :conditions => ['group_permissions.can_view = ?', true]

  after_create { |user| Group.create(:name => user.username).add_viewer(user) }
  after_destroy { |user| Group.find_by_name(user.username).destroy }

  def full_name
    "#{name} (#{username})"
  end

  def private_group
    Group.find_by_name(self.username)
  end

  def can_edit_group? group
    GroupPermission.exists?(:group_id => group, :user_id => self, :can_edit => true)
  end

  def can_view_page? page
    # TODO this is a smelly looping of selects, reconsider using a single hellish JOIN
    
    restriction_in_path = false
    # check if user belongs to a group that can view some of the ancestors or self
    for node in page.self_and_ancestors
      direct_access = PagePermission.exists_by_user_and_page(self, node, 'can_view')
      return true if direct_access
      unless page.viewer_groups.empty?
        restriction_in_path = true
      end
    end
    return !restriction_in_path
  end

  def can_edit_page? page
    # TODO this is a smelly looping of selects, reconsider using a single hellish JOIN

    restriction_in_path = false
    # check if user belongs to a group that can view some of the ancestors or self
    for node in page.self_and_ancestors
      direct_access = PagePermission.exists_by_user_and_page(self, node, 'can_edit')
      return true if direct_access
      unless page.editor_groups.empty?
        restriction_in_path = true
      end
    end
    return !restriction_in_path
  end

  def can_manage_page? page
    # TODO this is a smelly looping of selects, reconsider using a single hellish JOIN

    restriction_in_path = false
    # check if user belongs to a group that can view some of the ancestors or self
    for node in page.self_and_ancestors
      direct_access = PagePermission.exists_by_user_and_page(self, node, 'can_manage')
      return true if direct_access
      unless page.manager_groups.empty?
        restriction_in_path = true
      end
    end
    return !restriction_in_path
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