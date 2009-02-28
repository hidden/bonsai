class Group < ActiveRecord::Base
  has_many :group_permissions, :dependent => :destroy, :include => :user, :order => 'group_permissions.can_edit DESC, users.name ASC'
  has_many :users, :through => :group_permissions

  validates_presence_of :name
  validates_uniqueness_of :name

  def add_viewer user
    permission = GroupPermission.find_or_initialize_by_user_id_and_group_id(user.id, self.id)
    permission.can_view = true
    permission.save
  end

  def add_editor user
    permission = GroupPermission.find_or_initialize_by_user_id_and_group_id(user.id, self.id)
    permission.can_view = true
    permission.can_edit = true
    permission.save
  end
end
