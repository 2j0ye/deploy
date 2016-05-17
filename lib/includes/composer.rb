set :php_bin,               "php"
# Whether to use composer to install vendors.
# If set to false, it will use the bin/vendors script
set :use_composer,          false

# Whether to use composer to install vendors to a local temp directory.
set :use_composer_tmp,     false

# Path to composer binary
# If set to false, Capifony will download/install composer
set :composer_bin,          false

# Options to pass to composer when installing/updating
set :composer_options,      "--no-dev --verbose --prefer-dist --optimize-autoloader --no-progress"

# Whether to update vendors using the configured dependency manager (composer or bin/vendors)
set :update_vendors,        false

# run bin/vendors script in mode (upgrade, install (faster if shared /vendor folder) or reinstall)
set :vendors_mode,          "reinstall"

# Copy vendors from previous release
set :copy_vendors,          false


set :interactive_mode,      false
namespace :composer do
    desc "Gets composer and installs it"
    task :get, :roles => :app, :except => { :no_release => true } do
        console_pretty_print '--> Installing composer vendors'
        if use_composer_tmp
            # Because we always install to temp location we assume that we download composer every time.
            logger.debug "Downloading composer to #{$temp_destination}"
            run_locally "cd #{$temp_destination} && curl -s http://getcomposer.org/installer | #{php_bin}"
        else
            #AS curl could be uninstalled, we use the php way
            if !remote_file_exists?("#{latest_release}/composer.phar")
                run "#{try_sudo} sh -c 'cd #{latest_release} && php -r \"readfile(\\\"https://getcomposer.org/installer\\\");\" | php'"
            else
                run "#{try_sudo} sh -c 'cd #{latest_release} && #{php_bin} composer.phar self-update'"
            end
        end
        console_puts_ok
    end

    desc "Updates composer"

    desc "Runs composer to install vendors from composer.lock file"
    task :install, :roles => :app, :except => { :no_release => true } do

        if !composer_bin
            composer.get
            set :composer_bin, "#{php_bin} composer.phar"
        end

        options = "#{composer_options}"
        options += " --no-interaction"

        if use_composer_tmp
            logger.debug "Installing composer dependencies to #{$temp_destination}"
            run_locally "cd #{$temp_destination} && #{composer_bin} install #{options}"
        else
            run "#{try_sudo} sh -c 'cd #{latest_release} && #{composer_bin} install #{options}'"
        end
    end

    desc "Runs composer to update vendors, and composer.lock file"
    task :update, :roles => :app, :except => { :no_release => true } do
        if !composer_bin
            composer.get
            set :composer_bin, "#{php_bin} composer.phar"
        end

        options = "#{composer_options}"
        if !interactive_mode
            options += " --no-interaction"
        end

        run "#{try_sudo} sh -c 'cd #{latest_release} && #{composer_bin} update #{options}'"
    end

    desc "Dumps an optimized autoloader"
    task :dump_autoload, :roles => :app, :except => { :no_release => true } do
        if !composer_bin
            composer.get
            set :composer_bin, "#{php_bin} composer.phar"
        end

        run "#{try_sudo} sh -c 'cd #{latest_release} && #{composer_bin} dump-autoload --optimize'"
    end

    task :copy_vendors, :except => { :no_release => true } do
        run "vendorDir=#{latest_release}/vendor; if [ -d $vendorDir ] || [ -h $vendorDir ]; then cp -a $vendorDir #{latest_release}/vendor; fi;"
    end

    # Install composer to temp directory.
    # Not sure if this is required yet.
    desc "Dumps an optimized autoloader"
    task :dump_autoload_temp, :roles => :app, :except => { :no_release => true } do
        if !composer_bin
            composer.get_temp
            set :composer_bin, "#{php_bin} composer.phar"
        end

        logger.debug "Dumping an optimised autoloader to #{$temp_destination}"
        run_locally cd "#{$temp_destination} && #{composer_bin} dump-autoload --optimize"
    end
end

["composer:install", "composer:update"].each do |action|
    before action do
        if copy_vendors
            composer.composer.copy_vendors
        end
    end
end

after "deploy:finalize_update" do
    if use_composer
        if update_vendors
            composer.update
        else
            composer.install
        end
    end
end
