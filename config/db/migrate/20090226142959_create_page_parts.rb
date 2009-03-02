class CreatePageParts < ActiveRecord::Migration
  def self.up
    create_table :page_parts do |t|
      t.string :name, :null => false
      t.references :page, :null => false
      t.references :current_page_part_revision, :null => false
    end
  end

  def self.down
    drop_table :page_parts
  end
end
