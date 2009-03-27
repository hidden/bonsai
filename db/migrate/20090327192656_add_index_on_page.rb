class AddIndexOnPage < ActiveRecord::Migration
  def self.up
    add_index :pages, [:lft, :rgt]
  end

  def self.down
    drop_index :pages, [:lft, :rgt]
  end
end
