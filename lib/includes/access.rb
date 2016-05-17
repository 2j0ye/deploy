namespace :access do
  task :secure do
    logger.info "Secure with htaccess"

    set :htaccess_username, Capistrano::CLI.ui.ask("Username: ")
    set :htaccess_password, Capistrano::CLI.ui.ask("Password: ")

    # set :htpasswd_already_exist, remote_file_exists "File.exist?(File.join(shared_path, '.htpasswd'))"
    set :htpasswd_already_exist, remote_file_exists?(File.join(current_path, '.htpasswd'))
    set :htaccess_password_hashed, "#{htaccess_password}".crypt('httpauth')
    run "echo '#{htaccess_username}:#{htaccess_password_hashed}' >> #{File.join(current_path, '.htpasswd')}"

    # Edit .htaccess only if .htpasswd doesn't exist
    if !htpasswd_already_exist
      run "echo '' >> #{File.join(current_path, '.htaccess')}"
      run "echo '# Basic Auth' >> #{File.join(current_path, '.htaccess')}"
      run "echo 'AuthType Basic' >> #{File.join(current_path, '.htaccess')}"
      run "echo 'AuthName \"Restricted\"' >> #{File.join(current_path, '.htaccess')}"
      run "echo 'AuthUserFile #{File.join(current_path, '.htpasswd')}' >> #{File.join(current_path, '.htaccess')}"
      run "echo 'Require valid-user' >> #{File.join(current_path, '.htaccess')}"
    end
  end
end

after "deploy:finalize_update" do
    logger.info "Copy previous htpasswd"
    if remote_file_exists?(File.join(current_path, '.htpasswd'))
        run "cp #{current_path}/.htpasswd #{latest_release}/.htpasswd"
    end
end
