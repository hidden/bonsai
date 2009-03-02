class CreatePagePartRevisions < ActiveRecord::Migration
  def self.up
    create_table :page_part_revisions do |t|
      t.references :page_part, :null => false
      t.references :user, :null => false
      t.datetime :created_at, :null => false
      t.text :body, :null => false
    end
  end

  def self.down
    drop_table :page_part_revisions
  end
end
