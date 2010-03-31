class CreatePagePermissionsHistories < ActiveRecord::Migration
  def self.up
    create_table :page_permissions_histories do |t|
      t.references :page, :null => false
      t.references :user, :null => false
      t.references :group, :null => false

      t.integer :role
      t.integer :action
      t.datetime :created_at, :null => false
    end
  end

  def self.down
    drop_table :page_permissions_histories
  end
end
