class AddCompositeIndexOnPages < ActiveRecord::Migration
  def self.up
    remove_index :pages, :sid
    add_index :pages, [:parent_id, :sid]
  end

  def self.down
    remove_index :pages, [:parent_id, :sid]
    add_index :pages, :sid
  end
end
