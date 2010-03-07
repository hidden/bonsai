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
  has_many :file_versions, :through => :uploaded_files

  named_scope :find_all_public, :joins => "LEFT JOIN page_permissions pp ON pages.id = pp.page_id AND pp.can_view = 1", :conditions => "pp.id IS NULL"

  define_index do
    indexes page_parts_revisions.body, :as => :page_part_body
    indexes page_parts.name, :as => :page_part_name
    indexes pages.title, :as => :page_title
  end

  def to_sym
    self.id
  end

  def get_children_tree page,user
    Page.find_by_sql("SELECT  p.* FROM pages p
                      left join (
                      select page_id,
                             count(can_view) sum_can_view,
                             count(can_edit) sum_can_edit 
                      from page_permissions group by page_id) w on w.page_id=p.id
                      left join page_permissions a on a.page_id=p.id and (sum_can_view!=0 or sum_can_edit!=0)
                      left join groups q
                      ON q.id = a.group_id and q.name='#{user}' and (a.can_view=1 or a.can_edit=1 or a.can_manage=1)
                      where (p.lft BETWEEN #{page.lft} AND #{page.rgt})
                      and ((sum_can_view=0 and sum_can_edit=0)or (q.id is not null))
                      order by p.lft")
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

  def get_page_parts_by_date date
    page_parts = []
    for part in self.page_parts
      current_part = part.page_part_revisions.find(:first, :conditions => ['created_at <= ?', date], :order => "id DESC")
      page_parts << current_part if current_part
    end
    return page_parts
  end

  def files
    path = Path::UP_HISTORY + get_path
    entries = []  #entries - vsetky subory co su v adresari upload_history pre page
    files_without_db_entries = []  #files_without_db_entries - vsetky subory co su v adresari upload pre page
    entries = Dir.entries(path).select {|file| File.file?(path + file) } if File.directory?(path)
    uploaded = uploaded_files.select {|file| entries.include?(file.current_file_version.filename)}

    anonym_path = Path::ANONYM_UPLOAD_PATH + get_path
    files_without_db_entries = Dir.entries(anonym_path).select {|file| File.file?(anonym_path + file) } if File.directory?(anonym_path)
    anonym_files = files_without_db_entries.collect do |file|
      UploadedFile.new(:attachment_filename => file, :page_id => self.id) unless uploaded_files.collect(&:attachment_filename).include?(file)
    end

    (anonym_files.compact + uploaded).uniq.sort_by(&:attachment_filename)
  end

  def file_versions(file)
    if ((not file.nil?) and (file.page == self))
      file.file_versions
    else
      file = nil
    end
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
