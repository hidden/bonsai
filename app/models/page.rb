class Page < ActiveRecord::Base
  acts_as_nested_set
  validates_uniqueness_of :sid, :scope => :parent_id

  has_many :page_parts, :dependent => :destroy
  has_many :page_parts_revisions, :through => :page_parts, :source => :page_part_revisions, :order => 'created_at DESC'

  has_many :page_permissions, :dependent => :destroy
  has_many :viewer_groups, :through => :page_permissions, :class_name => 'Group', :source => :page, :conditions => ['page_permissions.can_view = ?', true]

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

  def add_viewer group
    permission = PagePermission.find_or_initialize_by_page_id_and_group_id(self.id, group.id)
    permission.can_view = true
    permission.save
  end
end
