namespace :bonsai do
  desc "Adds files to database"
  task :sanitize_uploads => :environment do
    Dir.glob("shared/upload/**/*").each do |file|
      next unless File.file?(file) # skip non-files
      filename_with_path = file.gsub("shared/upload/", "")
      filename = File.basename(file)
      full_path = File.dirname(file)
      path = File.dirname(filename_with_path).split('/')
      path = [] if path == ['.']
      page = Page.find_by_path(path)
      unless filename.match(/_version\d+/)
        # rename and update db
        extension = File.extname(filename)
        regex = Regexp.new("#{extension.gsub('.', '\\.')}$")
        new_filename = filename.gsub(regex, "_version1#{extension}")
        uploaded_file = page.uploaded_files.find_or_initialize_by_filename(filename)
        uploaded_file.current_file_version_id = 0 if uploaded_file.current_file_version.nil?
        version = uploaded_file.versions.find_or_initialize_by_version(1)
        version.content_type = "application/octet-stream" if version.content_type.blank?
        version.file = uploaded_file
        version.size = File.size(file)
        mtime = File.mtime(file)
        version.created_at = mtime if version.created_at.nil? or (mtime < version.created_at)
        version.save!
        FileUtils.mv(RAILS_ROOT + "/" + file, "#{RAILS_ROOT}/#{full_path}/#{new_filename}")
        uploaded_file.current_file_version = version
        uploaded_file.save!
      end
    end
  end
end