class CreateGroupPermissions < ActiveRecord::Migration
  def self.up
    create_table :group_permissions do |t|
      t.references :user, :null => false
      t.references :group, :null => false
      t.string :permission, :null => false
    end
  end

  def self.down
    drop_table :group_permissions
  end
end
