class AddLocaleToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :prefered_locale, :string
  end

  def self.down
    remove_column :users, :prefered_locale
  end
end
