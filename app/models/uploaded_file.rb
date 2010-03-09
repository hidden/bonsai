class UploadedFile < ActiveRecord::Base
  belongs_to :page
  has_many :versions, :class_name => "FileVersion", :foreign_key => "file_id", :order => 'version DESC', :dependent => :destroy
  belongs_to :current_version, :class_name => "FileVersion"

  def extension
    File.extname(filename)
  end
end
