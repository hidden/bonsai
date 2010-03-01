class FileVersion < ActiveRecord::Base
  belongs_to :uploaded_file
  belongs_to :user
  has_attachment :storage => :file_system, :path_prefix => "shared/upload", :size => 0.megabytes..15.megabytes

  validates_as_attachment

  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s + self.uploaded_file.page.get_path.chomp("/")
    File.join(RAILS_ROOT, file_system_path, *partitioned_path(thumbnail_name_for(thumbnail)))
  end

  def rename(name)
    self.filename = name
    self.save
  end

  def exist?(page_path)
    file = 'shared/upload' + page_path + self.filename
    File.file?(file)
  end

  def extension
    File.extname(filename).delete(".").downcase
  end

  # overrwrite this to do your own app-specific partitioning.
  # you can thank Jamis Buck for this: http://www.37signals.com/svn/archives2/id_partitioning.php
  def partitioned_path(*args)
    #("%08d" % attachment_path_id).scan(/..../) + args
    args
  end
end
