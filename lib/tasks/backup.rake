namespace :db do
  desc "Backup the database."
  task :backup => [:environment] do
    require 'ftools'
    datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    backup_folder = File.join('shared', 'backup', 'db')
    backup_file = File.join(backup_folder, "#{RAILS_ENV}_dump_#{datestamp}.sql")
    File.makedirs(backup_folder)
    config = ActiveRecord::Base.configurations[RAILS_ENV]
    `mysqldump -u #{config['username']} -p#{config['password']} -Q --add-drop-table -O add-locks=FALSE -O lock-tables=FALSE #{config['database']} > #{backup_file}`
    `gzip #{backup_file}`
    puts "Created backup: #{backup_file}"
  end
end

namespace :fileSystem do
  desc "Backup files on filesystem"
  task :backup_fileSystem do
    require 'ftools'
    datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    period = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]['backup_period']
    backup_path = File.join('shared', 'backup', 'fs')
    backup_folder = File.join(backup_path, "#{RAILS_ENV}_backup_#{datestamp}")
    File.makedirs(backup_folder)
    cp_r(File.join('shared', 'upload_history'), backup_folder) unless not File.exist?(File.join('shared', 'upload_history'))
    cp_r(File.join('shared', 'upload'), backup_folder) unless not File.exist?(File.join('shared', 'upload'))

    folders = Dir.entries(backup_path).sort.reject {|folder| folder == "." or folder == ".."}
    if (folders.length > period)
      rm_rf File.join(backup_path, folders.first)
    end
    puts "Created file backup: #{backup_folder}"
  end
end