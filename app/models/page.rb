class Page < ActiveRecord::Base
  acts_as_nested_set
  validates_uniqueness_of :sid, :scope => :parent_id

  has_many :page_parts, :dependent => :destroy

  def self.find_by_path path, current_user
    path = [nil] if path.empty?
    current = traverse_path path
    if current.nil?
      parent = nil
      parent = traverse_path path[0..path.size - 2] if path.size > 1
      if parent.nil?
        return nil unless path.size == 1 && Page.root.nil?  #we do not want to create new page in the middle of the tree, but we proceed if this is going to be the root page
      end
      #TODO: check for permission
      ActiveRecord::Base.transaction do
        current = Page.create(:title => path.last, :sid => path.last)
        current.move_to_child_of parent unless parent.nil?
        #TODO: co bolo skorej, vajce alebo sliepka? PagePart or its revision?
        first_revision = PagePartRevision.create(:user => current_user, :body => "This page does not hold any content yet", :page_part_id => 0)
        page_part = PagePart.create(:name => "body", :page => current, :current_page_part_revision => first_revision)
        first_revision.page_part = page_part
      end
    end
    return current
  end

  def self.traverse_path path
    path = [nil] if path.empty?
    parent_id = nil
    for chunk in path
      current = Page.find_by_parent_id_and_sid(parent_id, chunk)
      return nil if current.nil?
      parent_id = current.id
    end
    return current
  end

  def get_path
    path = ""
    self.ancestors.collect { |e| path = path + "/" + e.sid  }
    path = path + "/" + sid
  end
end