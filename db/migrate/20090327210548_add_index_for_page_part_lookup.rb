class AddIndexForPagePartLookup < ActiveRecord::Migration
  def self.up
    add_index :page_parts, [:page_id, :name]
  end

  def self.down
    drop_index :page_parts, [:page_id, :name]
  end
end
