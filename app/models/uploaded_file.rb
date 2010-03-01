class UploadedFile < ActiveRecord::Base
  belongs_to :page
  has_many :file_versions, :order => 'version DESC', :dependent => :destroy
  belongs_to :current_file_version, :class_name => 'FileVersion'

  validates_presence_of :attachment_filename

  def rename(name)
    self.attachment_filename = name
    self.save
  end
  
end
