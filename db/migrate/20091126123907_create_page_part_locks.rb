class CreatePagePartLocks < ActiveRecord::Migration
  def self.up
    create_table :page_part_locks do |t|
      t.integer :part_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :page_part_locks
  end
end
