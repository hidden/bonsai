class Group < ActiveRecord::Base
  has_many :group_permissions, :include => :user, :order => 'group_permissions.can_edit DESC, users.name ASC', :dependent => :destroy
  has_many :users, :through => :group_permissions
  has_many :page_permissions, :dependent => :destroy 

  has_many :viewer_users, :through => :group_permissions, :class_name => 'User', :source => :user, :conditions => ['group_permissions.can_view = ?', true]
  has_many :editor_users, :through => :group_permissions, :class_name => 'User', :source => :user, :conditions => ['group_permissions.can_edit = ?', true]
  has_many :group_permissions_histories, :dependent => :destroy
  has_many :page_permissions_histories, :dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  def add_viewer user
    if self.viewer_users.empty?
      self.group_permissions.each do |permission|
        if (permission.can_edit == true)
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
    if (self.users.empty?)
      self.destroy
    end
  end

  def remove_editor user
    permission = GroupPermission.find_by_user_id_and_group_id(user.id, self.id)
    if (self.editor_users.size == 1)
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

  def can_view_page? page
    # TODO this is a smelly looping of selects, reconsider using a single hellish JOIN

    restriction_in_path = false
    # check if user belongs to a group that can view some of the ancestors or self
    for node in page.self_and_ancestors
      direct_access = page.viewer_groups.include?(self)
      return true if direct_access
      unless page.viewer_groups.empty? && page.is_public?
        restriction_in_path = true
      end
    end
    return !restriction_in_path
  end

  def can_edit_page? page
    # TODO this is a smelly looping of selects, reconsider using a single hellish JOIN

    restriction_in_path = false
    # check if a group can view some of the ancestors or self
    for node in page.self_and_ancestors
      direct_access = page.editor_groups.include?(self)
      return true if direct_access
      unless page.editor_groups.empty? && page.is_editable?
        restriction_in_path = true
      end
    end
    return !restriction_in_path
  end

  def is_public?
    self.viewer_users.empty? ? true:false
  end

  def is_editable?
    false
  end

  def self.groups_visible_for_all
    groups = Group.find(:all, :joins => "JOIN group_permissions ON groups.id = group_permissions.group_id", :conditions => "group_permissions.can_view = 0 OR group_permissions.can_view = NULL")
    groups
  end

  def rename
    i = 1

    loop {
      tmp_name = self.name + "_group"
      tmp_name += i.to_s() unless i == 1
      new_name = Group.find_by_name(tmp_name)
      i += 1
      break if new_name.nil?
    }

    new_name = self.name + "_group"
    new_name += (i-1).to_s() unless (i-1) == 1

    self.name = new_name
    self.save!
  end
end
