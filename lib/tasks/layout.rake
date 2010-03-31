namespace :bonsai do
  desc "Install new layout"
  task :install do

    if !ENV['layout'].nil?
      if File.exist? ENV['layout']
        cp "#{ENV['layout']}", "#{RAILS_ROOT}/vendor/layouts"
        #prepare file name
        file_name = File.basename("#{ENV['layout']}")
        #prepare dir name
        dir_name = file_name[0, file_name.index('.')]
        FileUtils.chdir("#{RAILS_ROOT}/vendor/layouts")
        `tar -xvf #{file_name}`


        error = false
        unless File.exist? ("#{dir_name}/definition.yml")
          puts "ERROR: #{dir_name}/definition.yml does not exist!"
          error = true
        end
         unless File.exist? ("#{dir_name}/#{dir_name}.html.erb")
          puts "ERROR: #{dir_name}/#{dir_name}.html.erb does not exist!"
          error = true
        end
        unless File.exist? ("#{dir_name}/locales")
          puts "ERROR: #{dir_name}/locales does not exist!"
          error = true
        end
        unless File.exist? ("#{dir_name}/public")
          puts "ERROR: #{dir_name}/public does not exist!"
          error = true
        end

        if error != true
          #move images
          mv "#{RAILS_ROOT}/vendor/layouts/#{dir_name}/public/images", "#{RAILS_ROOT}/public/images/layouts/#{dir_name}"
          #move stylesheet definition
          mv "#{RAILS_ROOT}/vendor/layouts/#{dir_name}/public/#{dir_name}.css", "#{RAILS_ROOT}/public/stylesheets/"
          #move language definitions
          mv "#{RAILS_ROOT}/vendor/layouts/#{dir_name}/locales", "#{RAILS_ROOT}/config/locales/layouts/#{dir_name}"
          #move html erb file
          mv "#{RAILS_ROOT}/vendor/layouts/#{dir_name}/#{dir_name}.html.erb", "#{RAILS_ROOT}/app/views/layouts/"          
          #remove public folder
          rm_rf "#{RAILS_ROOT}/vendor/layouts/#{dir_name}/public"
          #remove archive
          rm_rf "#{RAILS_ROOT}/vendor/layouts/#{file_name}"
          #mv "#{RAILS_ROOT}/vendor/layouts/#{file_name}", "#{ENV['layout']}"
          puts "Layout test was succesfully installed."
        end

      else
        puts "ERROR cant find this file, please check tha path"
      end
    else
      puts "ERROR: You must specify layout to install"
    end
  end


  desc "Uninstall layout"
  task :uninstall => :environment do

    if !ENV['layout'].nil?

      pages_with_layout = Page.find_by_layout("#{ENV['layout']}")

      if pages_with_layout.nil?

        path = "#{RAILS_ROOT}/public/images/layouts/#{ENV['layout']}"
        if  File.exist? path
          rm_rf path
        end

        path = "#{RAILS_ROOT}/public/stylesheets/#{ENV['layout']}.css"
        if  File.exist? path
          rm_rf path
        end

        path = "#{RAILS_ROOT}/app/views/layouts/#{ENV['layout']}.html.erb"
        if  File.exist? path
          rm_rf path
        end

        path = "#{RAILS_ROOT}/config/locales/layouts/#{ENV['layout']}"
        if  File.exist? path
          rm_rf path
        end

        path = "#{RAILS_ROOT}/vendor/layouts/#{ENV['layout']}"
        if  File.exist? path
          rm_rf path
        end

        puts "Layout test was succesfully uninstalled."

      else
        puts "ERROR: Layout can not be uninstalled. This layout is currently used as layout on some pages."
      end
    else
      puts "ERROR: You must specify layout to uninstall."
    end
  end

end