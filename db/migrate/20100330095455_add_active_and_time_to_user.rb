class AddActiveAndTimeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :active, :boolean, :default=>true
    change_table :users do |t|
      t.timestamps
    end
  end

  def self.down
    remove_column :users, :active
    change_table :users do |t|
      t.remove_timestamps
    end
  end
end