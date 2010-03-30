class AddActiveAndTimeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :active, :boolean, :default=>true
    add_column :users, :regtime, :datetime
    add_column :users, :logtime, :datetime
  end

  def self.down
    remove_column :users, :regtime
    remove_column :users, :users
    remove_column :users, :active
  end
end