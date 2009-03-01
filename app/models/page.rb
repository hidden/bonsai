class Page < ActiveRecord::Base
  acts_as_nested_set
  validates_uniqueness_of :sid, :scope => :parent_id

  has_many :page_parts, :dependent => :destroy

  def self.find_by_path path
    path = [""] + path
    parent_id = nil
    for chunk in path
      current = Page.find_by_parent_id_and_sid(parent_id, chunk)
      return nil if current.nil?
      parent_id = current.id
    end
    return current
  end

  def get_path
    self.ancestors.collect {|node| node.sid}.join('/') + "/" + self[:sid]
  end
end