class Group < ActiveRecord::Base
  has_many :group_permissions, :dependent => :destroy, :include => :user, :order => 'group_permissions.can_edit DESC, users.name ASC'
  has_many :users, :through => :group_permissions

  has_many :viewer_users, :through => :group_permissions, :class_name => 'User', :source => :user, :conditions => ['group_permissions.can_view = ?', true]
  has_many :editor_users, :through => :group_permissions, :class_name => 'User', :source => :user, :conditions => ['group_permissions.can_edit = ?', true]

  validates_presence_of :name
  validates_uniqueness_of :name

  def add_viewer user
    if self.viewer_users.empty?
      self.group_permissions.each do |permission|
        if(permission.can_edit == true)
          permission.can_view = true
        end
        permission.save
      end
    end
    permission = GroupPermission.find_or_initialize_by_user_id_and_group_id(user.id, self.id)
    permission.can_view = true
    permission.save
  end

  def add_editor user
    permission = GroupPermission.find_or_initialize_by_user_id_and_group_id(user.id, self.id)
    permission.can_view = true unless self.viewer_users.empty?
    permission.can_edit = true
    permission.save
  end

  def remove_viewer user
    permission = GroupPermission.find_by_user_id_and_group_id(user.id, self.id)
    permission.destroy
    if(self.users.empty?)
      self.destroy
    end
  end

  def remove_editor user
    permission = GroupPermission.find_by_user_id_and_group_id(user.id, self.id)
    if(self.editor_users.size == 1)
      permission.destroy
      self.destroy
    else
      permission.can_edit = false
      permission.save
    end
  end

  def add_as_non_viewer user
    permission = GroupPermission.find_or_initialize_by_user_id_and_group_id(user.id, self.id)
    permission.can_view = false
    permission.save
  end

  def self.groups_visible_for_all
    groups = Group.find(:all, :joins => "JOIN group_permissions ON groups.id = group_permissions.group_id", :conditions => "group_permissions.can_view = 0 OR group_permissions.can_view = NULL")
    groups
  end
end
