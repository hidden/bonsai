desc "Backup database and filesystem."
task :backup => :environment do
  Rake::Task[ "db:backup" ].execute
  Rake::Task[ "filesystem:backup" ].execute
end

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

namespace :filesystem do
  desc "Backup files on filesystem"
  task :backup do
    require 'ftools'
    datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    period = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]['backup_period']
    backup_path = File.join('shared', 'backup', 'fs')
    backup_file = File.join(backup_path, "#{RAILS_ENV}_backup_#{datestamp}.tar")
    File.makedirs(backup_path)
    `tar -c -f #{backup_file} -C shared upload upload_history `

    files = Dir.entries(backup_path).sort.reject {|folder| folder == "." or folder == ".."}
    if (files.length > period)
      File.delete(File.join(backup_path, files.first))
      puts "Info: Oldest backup was deleted"
    end
    puts "Created file backup: #{backup_file}"
  end
end