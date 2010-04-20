class FbUserUidToUsers < ActiveRecord::Migration
def self.up
  add_column :users, :fb_id, :integer
  add_column :users, :email_hash, :string
end

def self.down
  remove_column :users, :fb_id
  remove_column :users, :email_hash
end
end
