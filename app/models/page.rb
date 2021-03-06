class Page < ActiveRecord::Base
  acts_as_nested_set
  validates_uniqueness_of :sid, :scope => :parent_id

  has_many :page_parts, :dependent => :destroy
  has_many :page_parts_revisions, :through => :page_parts, :source => :page_part_revisions, :order => 'id DESC'

  has_many :page_permissions, :dependent => :destroy
  has_many :viewer_groups, :through => :page_permissions, :class_name => 'Group', :source => :group, :conditions => ['page_permissions.can_view = ?', true]
  has_many :editor_groups, :through => :page_permissions, :class_name => 'Group', :source => :group, :conditions => ['page_permissions.can_edit = ?', true]
  has_many :manager_groups, :through => :page_permissions, :class_name => 'Group', :source => :group, :conditions => ['page_permissions.can_manage = ?', true]

  has_many :uploaded_files, :dependent => :destroy  
  has_many :page_permissions_histories, :dependent => :destroy

  # TODO toto je zle
  named_scope :find_all_public, :joins => "LEFT JOIN page_permissions pp ON pages.id = pp.page_id AND pp.can_view = 1", :conditions => "pp.id IS NULL"

  define_index do
    indexes :title
    indexes page_parts.name, :as => :part_names
    indexes page_parts.current_page_part_revision.body, :as => :content
    has :id, :as => :page_id
    where "was_deleted = 0"
    set_property :field_weights => {:title => 10, :part_names => 5, :content => 2}
  end

  def choose_ordering
    case self.ordering
      when 0
        "id"
      when 1
        "name"
      else "id"
    end
  end

  def ordered_page_parts
    self.page_parts.find(:all, :order => self.choose_ordering)
  end

  def inherited_permissions
     Page.first(:joins => {:page_permissions => :page}, :conditions => ["pages.lft < ? and pages.rgt > ?", self.lft, self.rgt])
  end

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
    self_and_ancestors.collect(&:sid).join('/') + '/'
  end

  def get_rel_path
    path = self_and_ancestors.collect(&:sid)
    path.shift
    path
  end

  def full_title
    self_and_ancestors.collect(&:title).reverse.join(' | ')
  end

  def resolve_parent_layout
    if self.parent.nil?
      nil
    else
      self.parent.resolve_layout
    end
  end

  def resolve_layout
    node_with_layout = Page.first(:conditions => ["(? BETWEEN lft AND rgt) AND layout IS NOT NULL", self.lft], :order => "lft DESC")
    return (node_with_layout.nil?) ? 'default' : node_with_layout.layout
  end

   def home_page_by_layout
    home_page = Page.first(:conditions => ["(lft <= ? AND rgt >= ?) AND layout = ?", self.lft, self.rgt, resolve_layout], :order => "lft desc")
    return (home_page.nil?) ? nil : home_page
   end

  def parents_by_layout
    unless home_page_by_layout.nil?
      parents = Page.find_by_sql ["select * from pages where (lft < ? AND rgt > ?) and (lft >= ? and rgt <= ?) order by lft asc", self.lft, self.rgt, home_page_by_layout.lft, home_page_by_layout.rgt]
    end
    return (parents.nil?) ? nil : parents
  end

  def resolve_part part_name
    condition =  "(? BETWEEN pages.lft AND pages.rgt)"
    condition << " AND page_parts.name = ? AND page_part_revisions.was_deleted = ?"
    condition << " AND page_parts.current_page_part_revision_id = page_part_revisions.id"
    latest_part_revision = PagePartRevision.first(:joins => {:page_part => :page}, :conditions => [condition, self.lft, part_name, false], :order => "pages.lft DESC")
    latest_part_revision.nil? ? nil : latest_part_revision.body
  end

  def get_page_parts_by_date date
    page_parts = []
    for part in self.page_parts
      current_part = part.page_part_revisions.find(:first, :conditions => ['created_at <= ?', date], :order => "id DESC")
      page_parts << current_part if current_part
    end
    return page_parts
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

  def layout_parts
    definition = "vendor/layouts/#{resolve_layout}/definition.yml"
    if File.exist?(definition)
      layout = YAML.load_file(definition)
      unless layout.nil?
        return layout['parts']
      end
    end
  end

  def inherited_layout
    node_with_layout = Page.first(:conditions => ["(? BETWEEN lft AND rgt) AND layout IS NOT NULL", self.lft], :order => "lft DESC")
    return (node_with_layout.nil? ? nil : node_with_layout.layout)
  end

  def parent_layout
    unless parent.nil?
      node_with_layout = Page.first(:conditions => ["(? BETWEEN lft AND rgt) AND layout IS NOT NULL", parent.lft], :order => "lft DESC")
    end
    return (node_with_layout.nil? ? nil : node_with_layout.layout)
  end

  def last_update
    unless self.id.nil?
      last_sql = "select max(ppr.created_at) as last_update from page_part_revisions ppr, page_parts pp where  pp.page_id = #{self.id} and pp.current_page_part_revision_id = ppr.id"
      PagePartRevision.find_by_sql(last_sql).first.last_update
    end  
  end

  def is_root?
    self.lft == 1
  end

  def get_page_revisions
      revisions=PagePartRevision.find_by_sql ["select p.id as pg_id, p.title as pg_name, p.sid as pg_path, pp.name as pg_part_name,
                                                  (select count(p1.id) from pages p1
                                                   right join page_parts pp1 on p1.id=pp1.page_id
                                                   right join page_part_revisions ppr1 on pp1.id=ppr1.page_part_id
                                                   where ppr1.id<ppr.id AND p1.id=p.id) as prev_rev_count, ppr.*
                                            from pages p
                                            right join page_parts pp on p.id=pp.page_id
                                            right join page_part_revisions ppr on pp.id=ppr.page_part_id
                                            where p.id=? order by ppr.id", self.id]
    return revisions
  end

  def get_page_subtree_revisions user
    ids =  user.find_all_accessible_pages.collect(&:id)
      revisions=PagePartRevision.find_by_sql ["select p.id as pg_id, p.title as pg_name, p.sid as pg_path, pp.name as pg_part_name,
                                                  (select count(p1.id) from pages p1
                                                   right join page_parts pp1 on p1.id=pp1.page_id
                                                   right join page_part_revisions ppr1 on pp1.id=ppr1.page_part_id
                                                   where ppr1.id<ppr.id AND p1.id=p.id) as prev_rev_count, ppr.*
                                            from pages p
                                            right join page_parts pp on p.id=pp.page_id
                                            right join page_part_revisions ppr on pp.id=ppr.page_part_id
                                            where p.lft>=? AND p.rgt<=? AND p.id in (?) order by ppr.id", self.lft, self.rgt, ids]
    return revisions
  end
end