class Page < ActiveRecord::Base
  acts_as_nested_set

  has_many :page_parts, :dependent => :destroy

  def self.find_by_path path, current_user
    path = [nil] if path.empty?
    current = traverse_path path
    if current.nil?
      parent = traverse_path path[0..path.size - 2]
      if parent.nil?
        return nil  #we do not want to create new page in the middle of the tree
      else
        #TODO: check for permission
        current = Page.new(:title => path.last, :sid => path.last)
        current.save!
        current.move_to_child_of parent #we need to save the page before in order to call this
        #create parts
        #TODO: co bolo skorej, vajce alebo sliepka? PagePart alebo jej revizia?
        first_revision = PagePartRevision.create(:user => current_user, :body => "This page does not hold any content yet", :page_part_id => 0)
        page_part = PagePart.create(:name => "body", :page => current, :current_page_part_revision => first_revision)
        first_revision.page_part = page_part
      end
    end
    return current
    end

  def self.traverse_path path
    path = [nil] if path.empty?
    parent_id = 0
    for chunk in path
      current = Page.find_by_parent_id_and_sid(parent_id, chunk)
      return nil if current.nil?
      parent_id = current.id
    end
    return current
  end
end
