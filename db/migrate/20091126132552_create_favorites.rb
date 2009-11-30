class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.references :user, :null => false
      t.references :page, :null => false
    end

    add_index :favorites, :user_id
  end

  def self.down
    drop_table :favorites
  end
end
