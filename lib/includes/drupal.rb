# v1.0.2
namespace :drupal do

  desc "Symlink files dir from shared path to latest release path"
  task :symlink, :except => { :no_release => true } do
    domains.each do |domain|
      run "rm -rf #{latest_release}/sites/#{domain}/files"
      run "ln -nfs #{shared_path}/#{domain}/files #{latest_release}/sites/#{domain}/files"
      run "rm -f #{latest_release}/sites/#{domain}/settings.php"
      run "ln -nfs #{shared_path}/#{domain}/settings.php #{latest_release}/sites/#{domain}/settings.php"
    end
    run "rm -f #{latest_release}/.htaccess"
    run "ln -nfs #{shared_path}/.htaccess #{latest_release}/.htaccess"
    run "rm -f #{latest_release}/robots.txt"
    run "ln -nfs #{shared_path}/robots.txt #{latest_release}/robots.txt"
  end

  desc "Create Drupal init files (htaccess, settings.php, robots.txt) optionnaly create database"
  task :setup, :roles => [:web] do

    upload(".htaccess", "#{shared_path}/.htaccess")
    upload("robots.txt", "#{shared_path}/robots.txt")

    domains.each do |domain|

      set :db_host, Capistrano::CLI.ui.ask("Database Host for #{domain} domain :")
      set :db_name, Capistrano::CLI.ui.ask("Database Name for #{domain} domain  :")
      set :db_user, Capistrano::CLI.ui.ask("Database Username for #{domain} domain  :")
      set :db_pass, Capistrano::CLI.ui.ask("Database Password for #{domain} domain  :")

      put(File.read("settings.php") % [db_host, db_name, db_user, db_pass, db_user, db_pass, db_host, db_name], "#{shared_path}/#{domain}/settings.php")

      if Capistrano::CLI.ui.ask("Do you want to create '#{db_name}' database on '#{db_host}' and grant permissions to '#{db_user}' ? (y/n): ") == 'y'

        set :db_admin_user, Capistrano::CLI.ui.ask("MySQL Admin username: ")
        set :db_admin_pass, Capistrano::CLI.password_prompt("MySQL Admin password: ")
        if database_exists?(db_host, db_admin_user,db_admin_pass,db_name)
          logger.info "Database #{db_name} already exists. Creation aborted."
        else
          create_database(db_host, db_admin_user,db_admin_pass,db_name)
          setup_database_permissions(db_host, db_admin_user,db_admin_pass,db_name,db_user,db_pass)
        end
      end
    end
  end

  desc "Cleanup files"
  task :cleanup_files, :roles => [:web] do
    console_pretty_print '--> Cleanup drupal files'
    run "rm -rf #{release_path}/build"
    run "rm -f #{release_path}/build.properties"
    run "rm -rf #{release_path}/deploy"
    run "rm -rf #{release_path}/config"
    run "rm -rf #{release_path}/.git"
    run "rm -f #{release_path}/.gitignore"
    run "rm -f #{release_path}/README.md"
    run "rm -f #{release_path}/COPYRIGHT.txt #{release_path}/README.txt #{release_path}/web.config #{release_path}/MAINTAINERS.txt #{release_path}/REVISION #{release_path}/LICENCE.txt #{release_path}/UPGRADE.txt #{release_path}/INSTALL*.txt #{release_path}/CHANGELOG.txt #{release_path}/install.php"
    run "cd #{release_path}; find -L . -type d ! -path \"./sites/default/files/*\" -exec chmod 750 {} \\;"
    run "cd #{release_path}; find -L . -type f ! -path \"./sites/default/files/*\" -exec chmod 640 {} \\;"
    run "cd #{release_path}; find -L . -type f ! -path \"./*\" -exec chmod 444 {} \\;"
    run "cd #{release_path}; chmod 444 ./sites/default/settings.php"
    console_puts_ok
  end

  before "deploy:cleanup" do
    try_sudo "#{try_sudo} chmod -R 700 #{releases_path}/*"
    count = fetch(:keep_releases, 5).to_i
    run "ls -1dt #{releases_path}/* | tail -n +#{count + 1} | #{try_sudo} xargs chmod -R 700"
  end
end

before "deploy:update_code" do
    msg = "--> Updating code base with #{deploy_via} strategy"

    if logger.level == Capistrano::Logger::IMPORTANT
        pretty_errors
        puts msg
    else
        puts msg.green
    end
end

after "deploy:create_symlink" do
    drupal.cleanup_files
    puts "--> Successfully deployed!".green
end
