class AddIndexOnPagePartRevisions < ActiveRecord::Migration
  def self.up
    add_index :page_part_revisions, :page_part_id
  end

  def self.down
    drop_index :page_part_revisions, :page_part_id
  end
end
