class UploadedFile < ActiveRecord::Base
  belongs_to :page
  has_many :versions, :order => 'version DESC', :class_name => 'FileVersion', :foreign_key => 'file_id', :dependent => :destroy
  belongs_to :current_file_version, :class_name => 'FileVersion'

  validates_presence_of :filename

  def extension
    File.extname(filename)
  end

  def extension_type
    extension.downcase.delete('.')
  end
end
