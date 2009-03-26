class AddSecureTokenToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :token, :string, :null => false, :limit => 32
    User.all.each do |user|
      user.generate_unique_token
      user.save
    end
    add_index :users, :token, :unique => true
  end

  def self.down
    remove_column :users, :token
  end
end
