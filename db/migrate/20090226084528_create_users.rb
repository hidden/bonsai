class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username, :null => false
      t.string :name, :null => false
    end
  end

  def self.down
    drop_table :users
  end
end
