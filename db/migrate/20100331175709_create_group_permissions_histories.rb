class CreateGroupPermissionsHistories < ActiveRecord::Migration
  def self.up
    create_table :group_permissions_histories do |t|
      t.references :user, :editor, :null => false
      t.references :group, :null => false
      t.references :user, :null => false

      t.integer :role
      t.integer :action
      t.datetime :created_at, :null => false
    end
  end

  def self.down
    drop_table :group_permissions_histories
  end
end
