class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :title, :null => false
      t.string :sid
      t.references :parent
      t.integer :lft, :null => false
      t.integer :rgt, :null => false
    end
    add_index :pages, :sid
  end

  def self.down
    drop_table :pages
  end
end
