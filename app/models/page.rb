class Page < ActiveRecord::Base
  acts_as_nested_set
  validates_uniqueness_of :sid, :scope => :parent_id


  has_many :page_parts, :dependent => :destroy, :order => 'name'
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
      current = self.find_by_parent_id_and_sid(parent_id, chunk)
      return nil if current.nil?
      parent_id = current.id
    end
    return current
  end

  def get_path
    self.self_and_ancestors.collect {|node| node.sid}.join('/') + '/'
  end

  def get_rel_path
    a = self.self_and_ancestors.collect {|node| node.sid }
    a.delete_at(0)
    return a
  end

  def full_title
    self.self_and_ancestors.collect {|node| node.title}.reverse.join(' | ')
  end

  def resolve_layout
    node_with_layout = Page.first(:conditions => ["(? BETWEEN lft AND rgt) AND layout IS NOT NULL", self.lft], :order => "lft DESC")
    return node_with_layout.nil? ? 'application' : node_with_layout.layout
  end

  def resolve_part part_name
    condition =  "(? BETWEEN pages.lft AND pages.rgt)"
    condition << " AND page_parts.name = ? AND page_part_revisions.was_deleted = ?"
    condition << " AND page_parts.current_page_part_revision_id = page_part_revisions.id"
    latest_part_revision = PagePartRevision.first(:joins => {:page_part => :page}, :conditions => [condition, self.lft, part_name, false], :order => "pages.lft DESC")
    latest_part_revision.nil? ? nil : latest_part_revision.body
  end

  def files
    uploaded_file_names = self.uploaded_files.collect(&:filename)
    path = 'shared/upload' + get_path
    entries = File.directory?(path) ? Dir.entries(path) : []
    files_from_file_system = entries.reject do |file|
      uploaded_file_names.include?(file) or !File.file?(path + file) 
    end
    self.uploaded_files + files_from_file_system
  end

  def add_viewer group
    if self.viewer_groups.empty?
      self.page_permissions.each do |permission|
        if (permission.can_edit == true || permission.can_manage == true)
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
        if (permission.can_manage == true)
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
    PagePermission.first(:joins => :page, :conditions => ["? BETWEEN pages.lft AND pages.rgt AND page_permissions.can_view = ?", self.lft, true]).nil?
  end

  def is_editable?
    self.editor_groups.empty?
    #PagePermission.first(:joins => :page, :conditions => ["? BETWEEN pages.lft AND pages.rgt AND page_permissions.can_edit = ?", self.lft, true]).nil?
  end
end
