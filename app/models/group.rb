class Group < ActiveRecord::Base
  has_many :group_permissions, :dependent => :destroy
  has_many :users, :through => :group_permissions

  validates_presence_of :name
  validates_uniqueness_of :name

  def add_viewer user
    add_user_permission user, 'view'
  end

  def add_editor user
    add_user_permission user, 'edit'
  end

  private
  def add_user_permission user, permission
    group_permissions << GroupPermission.create(:user => user, :group => self, :permission => permission)
  end
end
