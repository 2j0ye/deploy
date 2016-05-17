set :use_makefile,   false
set :remote_drush, "drush"
set :makefile, "makefile"
set :revert_features, true
set :use_ckeditor, false
set :clear_cache, false
set :updatedb, true
# v1.0.1
namespace :drush do
  task :default do
  end

  desc "Drush cache clear"
  task :cc, :except => { :no_release => true } do
    console_pretty_print '--> Clearing cache'
    domains.each do |domain|
      run "cd #{release_path}; #{remote_drush} --uri=#{domain} cc all"
    end
    console_puts_ok
  end

  desc "Drush make"
  task :make, :except => { :no_release => true } do
      console_pretty_print '--> Making Drupal Core and dependencies with makefile'
      run "cd #{release_path}; #{remote_drush} make #{makefile} -y"
      console_puts_ok
  end

  desc "Drush updatedb"
  task :updatedb, :except => { :no_release => true } do
      console_pretty_print '--> Update website, as update.php script does'
      domains.each do |domain|
        run "cd #{release_path}; #{remote_drush}  updatedb --uri=#{domain} -y"
      end
      console_puts_ok
  end
  desc "Drush maintenance mode on"
  task :maintenance_on, :except => { :no_release => true } do
      console_pretty_print '--> Maintenance mode on'
      domains.each do |domain|
        run "cd #{current_path}; #{remote_drush} vset maintenance_mode 1"
      end
      console_puts_ok
  end
  desc "Drush maintenance mode off"
  task :maintenance_off, :except => { :no_release => true } do
      console_pretty_print '--> Maintenance mode off'
      domains.each do |domain|
        run "cd #{release_path}; #{remote_drush} vset maintenance_mode 0"
      end
      console_puts_ok
  end

  desc "Drush features revert"
  task :features, :except => { :no_release => true } do
      console_pretty_print '--> Revert all features on website'
      run "cd #{release_path}; #{remote_drush} fra  -y"
      console_puts_ok

  end

  desc "Drush download Ckeditor"
  task :ckeditor, :except => { :no_release => true } do
        console_pretty_print '--> Download CKeditor sources'
        run "cd #{release_path}; #{remote_drush}  ckeditor-download sites/all/modules/ckeditor/ckeditor/ckeditor"
        console_puts_ok
  end

  namespace :web do
    desc "Set Drupal maintainance mode to online."
    task :enable, :except => { :no_release => true } do
      console_pretty_print '--> Set Drupal maintainance mode to online'
      set(:domain) do
        Capistrano::CLI.ui.ask("Domain? (all or #{domains}) ") { |q| q.validate = /\A\w+\Z/ }
      end unless exists?(:q)

      php = 'variable_set("site_offline", FALSE)'

      if domain == 'all'
        domains.each do |domain|
          run "cd #{release_path}; #{remote_drush} --uri=#{domain} php-eval '#{php}'"
        end
      else
        run "cd #{release_path}; #{remote_drush} --uri=#{domain} php-eval '#{php}'"
      end
      console_puts_ok
    end

    desc "Set Drupal maintainance mode to off-line."
    task :disable, :except => { :no_release => true } do
      console_pretty_print '--> Set Drupal maintainance mode to off-line'
      set(:domain) do
        Capistrano::CLI.ui.ask("Domain? (all or #{domains}) ") { |q| q.validate = /\A\w+\Z/ }
      end unless exists?(:q)

      php = 'variable_set("site_offline", TRUE)'
      if domain == 'all'
        domains.each do |domain|
          run "cd #{release_path}; #{remote_drush} --uri=#{domain} php-eval '#{php}'"
        end
      else
        run "cd #{release_path}; #{remote_drush} --uri=#{domain} php-eval '#{php}'"
      end
      console_puts_ok
    end

    desc "Drush custom command"
    task :custom, :except => { :no_release => true } do
      set(:command) do
        Capistrano::CLI.ui.ask("Command to execute:")
      end unless exists?(:command)
      set(:domain) do
        Capistrano::CLI.ui.ask("Domain? (all or #{domains}) ") { |q| q.validate = /\A\w+\Z/ }
      end unless exists?(:q)
      if domain == 'all'
        domains.each do |domain|
          run "cd #{release_path}; #{remote_drush} --uri=#{domain} #{command}"
        end
      else
        run "cd #{release_path}; #{remote_drush} --uri=#{domain} #{command}"
      end
      console_puts_ok
    end
  end

  namespace :files do
     desc "Create files backup"
     task :default do
       console_pretty_print '--> Create files backup'
       domains.each do |domain|
         dump_path = "#{shared_path}/backups/files"
         filename = "#{application}-#{stage}-#{domain}_files_#{Time.now.strftime("%Y%m%d%H%M%S")}.tar.gz"
         run "mkdir -p #{dump_path}"
         run "cd #{shared_path}/#{domain}/files; tar czf #{dump_path}/#{filename} *"
       end
       console_puts_ok
     end

     desc "Backup and download files directories"
     task :dl, :except => { :no_release => true } do
       console_pretty_print '--> Backup and download files directories'
       drush::files::default
       domains.each do |domain|
          dump_path = "#{shared_path}/backups/files"
          dumps = capture("ls -xt #{dump_path}").split.reverse
          run_locally "mkdir -p backups/files"
          get("#{dump_path}/#{dumps.last}", "./backups/files/#{dumps.last}")
       end
       console_puts_ok
     end

     desc "Upload and restore files directories"
     task :ul, :except => { :no_release => true } do
       console_pretty_print '--> Backup and download files directories'
       domains.each do |domain|
          dumps = `ls -xt ./backups/files/`.split.reverse
          logger.info("Specify the files_backup file for '#{domain}' domain (must be in local ./backups/files/ folder)")
          prompt_with_default(:filename, dumps.last)
          run "mkdir -p #{shared_path}/backups/files"
          upload("./backups/files/#{filename}", "#{shared_path}/backups/files/#{filename}")
          run "cd #{shared_path}/#{domain}/files; tar xvf #{shared_path}/backups/files/#{filename}"
       end
       console_puts_ok
     end

   end

   namespace :db do
     desc "Database backup"
     task :default, :except => { :no_release => true } do
       console_pretty_print '--> Database backup'
       run "mkdir -p #{shared_path}/backups/database/"
       domains.each do |domain|
         filename = "#{application}-#{stage}-#{domain}_database_#{Time.now.strftime("%Y%m%d%H%M%S")}.sql"
         dump_path = "#{shared_path}/backups/database"
         run "cd #{current_path}; #{remote_drush} --uri=#{domain} sql-dump --structure-tables-key=common > #{dump_path}/#{filename}"
         run "cd #{dump_path}; gzip #{filename}"
       end
       console_puts_ok
     end

   desc "Database backup && Download"
    task :dl, :except => { :no_release => true } do
      run "mkdir -p #{shared_path}/backups/database/"
      domains.each do |domain|
         filename = "#{application}-#{stage}-#{domain}_database_#{Time.now.strftime("%Y%m%d%H%M%S")}.sql"
         dump_path = "#{shared_path}/backups/database"
         run "cd #{current_path}; #{remote_drush} --uri=#{domain} sql-dump --structure-tables-key=common > #{dump_path}/#{filename}"
         dumps = capture("ls -xt #{dump_path}").split.reverse
         run_locally "mkdir -p ./backups/database"
         get("#{dump_path}/#{dumps.last}", "./backups/database/#{dumps.last}")
      end
    end

    desc "Backup Upload and Restore database backup"
    task :ul, :except => { :no_release => true } do
      domains.each do |domain|
        dumps = `ls -xt ./backups/database/`.split.reverse
        logger.info("Specify the database backup (.sql) file for '#{domain}' domain (must be in local ./backups/database/ folder)")
        prompt_with_default(:filename, dumps.last)
        run "mkdir -p #{shared_path}/backups/database"
        upload("./backups/database/#{filename}", "#{shared_path}/backups/database/#{filename}")
        drush::db::default
        if Capistrano::CLI.ui.ask("Are you sure you want to restore #{filename} for #{application} - #{stage} - #{domain} ? (y/n): ") == 'y'

          run "cd #{current_path}; `#{remote_drush} --uri=#{domain} sql-connect` < #{shared_path}/backups/database/#{filename} " do |channel, stream, data|
            raise Capistrano::Error, "unexpected output from mysql: " + data
          end
          logger.info "Restored successfully."
         else
          logger.info "Operation aborted."
        end
      end
    end
  end
end

after "deploy:update_code" do
    if use_makefile
        drush.make
    end
end

after "drush:make" do
  if use_makefile
     drush.maintenance_on
     drupal.symlink

     if revert_features
       drush.features
     end
     if updatedb
       drush.updatedb
     end
     if use_ckeditor
       drush.ckeditor
     end
     if clear_cache
       drush.cc
     end
     drush.maintenance_off
  end
end
