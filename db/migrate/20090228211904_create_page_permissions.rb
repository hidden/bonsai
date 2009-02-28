class CreatePagePermissions < ActiveRecord::Migration
  def self.up
    create_table :page_permissions do |t|
      t.references :page
      t.references :group
      t.boolean :can_view
      t.boolean :can_edit
      t.boolean :can_manage
    end
  end

  def self.down
    drop_table :page_permissions
  end
end
