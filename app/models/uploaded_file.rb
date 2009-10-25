class UploadedFile < ActiveRecord::Base
  belongs_to :page
  belongs_to :user
  has_attachment :storage => :file_system, :path_prefix => "shared/upload", :size => 0.megabytes..15.megabytes

  validates_as_attachment

  # Gets the full path to the filename in this format:
  #
  #   # This assumes a model name like MyModel
  #   # public/#{table_name} is the default filesystem path
  #   RAILS_ROOT/public/my_models/5/blah.jpg
  #
  # Overwrite this method in your model to customize the filename.
  # The optional thumbnail argument will output the thumbnail's filename. 
  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s + self.page.get_path.chomp("/")
    File.join(RAILS_ROOT, file_system_path, *partitioned_path(thumbnail_name_for(thumbnail)))
  end

  def rename(name)
      self.filename = name
      self.save
  end


  # overrwrite this to do your own app-specific partitioning.
  # you can thank Jamis Buck for this: http://www.37signals.com/svn/archives2/id_partitioning.php 
  def partitioned_path(*args)
    #("%08d" % attachment_path_id).scan(/..../) + args
    args
  end
end
