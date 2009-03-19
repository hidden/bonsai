class Page < ActiveRecord::Base
  acts_as_nested_set
  validates_uniqueness_of :sid, :scope => :parent_id

  has_many :page_parts, :dependent => :destroy
  has_many :page_parts_revisions, :through => :page_parts, :source => :page_part_revisions, :order => 'created_at DESC, id DESC'

  has_many :page_permissions, :dependent => :destroy
  has_many :viewer_groups, :through => :page_permissions, :class_name => 'Group', :source => :group, :conditions => ['page_permissions.can_view = ?', true]
  has_many :editor_groups, :through => :page_permissions, :class_name => 'Group', :source => :group, :conditions => ['page_permissions.can_edit = ?', true]
  has_many :manager_groups, :through => :page_permissions, :class_name => 'Group', :source => :group, :conditions => ['page_permissions.can_manage = ?', true]

  has_many :uploaded_files, :dependent => :destroy

  def self.find_by_path path
    full_path = [nil] + path
    parent_id = nil
    for chunk in full_path
      current = Page.find_by_parent_id_and_sid(parent_id, chunk)
      return nil if current.nil?
      parent_id = current.id
    end
    return current
  end

  def get_path
    self.self_and_ancestors.collect {|node| node.sid}.join('/') + '/'
  end

  def full_title
    self.self_and_ancestors.collect {|node| node.title}.reverse.join(' | ')
  end

  def resolve_layout
    # TODO rewrite to one sql select
    node_with_layout = self.self_and_ancestors.reverse.detect {|node| not node.layout.nil? }
    return node_with_layout.nil? ? 'application' : node_with_layout.layout
  end

  def resolve_part part_name
    # TODO rewrite to one sql select
    for node in self.self_and_ancestors.reverse
      part = PagePart.find_by_page_id_and_name(node.id, part_name)
      unless part.nil?
        return part.current_page_part_revision.body unless part.current_page_part_revision.was_deleted?
      end
    end
    return nil
  end

  def add_viewer group
    if self.viewer_groups.empty?
      self.page_permissions.each do |permission|
        if(permission.can_edit == true || permission.can_manage == true)
          permission.can_view = true
        end
        permission.save
      end
    end
    permission = PagePermission.find_or_initialize_by_page_id_and_group_id(:page_id => self.id, :group_id => group.id)
    permission.can_view = true
    permission.save!
  end

  def add_editor group
    if self.editor_groups.empty?
      self.page_permissions.each do |permission|
        if(permission.can_manage == true)
          permission.can_edit = true
        end
        permission.save
      end
    end
    permission = PagePermission.find_or_initialize_by_page_id_and_group_id(:page_id => self.id, :group_id => group.id)
    permission.can_view = true unless self.viewer_groups.empty?
    permission.can_edit = true
    permission.save!
  end

  def add_manager group
    permission = PagePermission.find_or_initialize_by_page_id_and_group_id(:page_id => self.id, :group_id => group.id)
    permission.can_view = true unless self.viewer_groups.empty?
    permission.can_edit = true unless self.editor_groups.empty?
    permission.can_manage = true
    permission.save!
  end

  def remove_viewer group
    permission = PagePermission.find_by_page_id_and_group_id(self.id, group.id)
    permission.destroy
  end

  def remove_editor group
    permission = PagePermission.find_by_page_id_and_group_id(self.id, group.id)
    permission.can_edit = false
    permission.can_manage = false
    permission.save
  end

  def remove_manager group
    permission = PagePermission.find_by_page_id_and_group_id(self.id, group.id)
    permission.can_manage = false
    permission.save
  end

  def is_public?
    self.viewer_groups.empty? ? true:false
  end

  def is_editable?
    self.editor_groups.empty? ? true:false
  end
end
