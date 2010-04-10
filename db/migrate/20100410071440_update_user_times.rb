class UpdateUserTimes < ActiveRecord::Migration
  def self.up
    remove_column :users, :regtime
    remove_column :users, :logtime
  end

  def self.down
    add_column :users, :regtime, :time
    add_column :users, :logtime, :time
  end
end
