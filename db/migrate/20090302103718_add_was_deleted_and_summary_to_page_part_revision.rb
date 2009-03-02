class AddWasDeletedAndSummaryToPagePartRevision < ActiveRecord::Migration
  def self.up
    add_column :page_part_revisions, :was_deleted, :boolean
    add_column :page_part_revisions, :summary, :string
  end

  def self.down
    remove_column :page_part_revisions, :summary
    remove_column :page_part_revisions, :was_deleted
  end
end
