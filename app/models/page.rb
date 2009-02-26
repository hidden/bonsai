class Page < ActiveRecord::Base
  #acts_as_nested_set

  has_many :page_parts, :dependent => :destroy

  def self.find_by_path path
    path = [nil] if path.empty?
    parent_id = nil
    for chunk in path
      current = Page.find_by_parent_id_and_sid(parent_id, chunk)
      return nil if current.nil?
      parent_id = current.id
    end
    return current
  end
end
