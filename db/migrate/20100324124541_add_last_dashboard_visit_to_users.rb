class AddLastDashboardVisitToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_dashboard_visit, :datetime
  end

  def self.down
    remove_column :users, :last_dashboard_visit
  end
end
