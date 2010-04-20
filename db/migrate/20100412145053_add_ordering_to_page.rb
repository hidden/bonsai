class AddOrderingToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :ordering, :integer
  end

  def self.down
    remove_column :users, :ordering   
  end
end
