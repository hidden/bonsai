namespace :db do
  desc "Backup the database."
  task :backup => [:environment] do
    datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    backup_folder = File.join('shared', 'backup')
    backup_file = File.join(backup_folder, "#{RAILS_ENV}_dump_#{datestamp}.sql")
    File.makedirs(backup_folder)
    config = ActiveRecord::Base.configurations[RAILS_ENV]
    `mysqldump -u #{config['username']} -p#{config['password']} -Q --add-drop-table -O add-locks=FALSE -O lock-tables=FALSE #{config['database']} > #{backup_file}`
    `gzip #{backup_file}`
    puts "Created backup: #{backup_file}"
  end
end