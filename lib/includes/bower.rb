set :use_bower,          false

set :bower_mode,         'local' # local or server
set :bower_directory,    'bower_components'

namespace :bower do
  desc "run bower install on localhost and upload files to server"
  task :install, :except => { :no_release => true } do
    console_pretty_print '--> Installing bower components'
    if bower_mode == 'local'
      run_locally "bower install";
      run_locally "tar -czf #{bower_directory}.tar.gz #{bower_directory}"
      top.upload "#{bower_directory}.tar.gz", release_path + '/', :via => :scp
      run "cd #{release_path} && tar -xzf #{bower_directory}.tar.gz && rm -rf #{bower_directory}.tar.gz"
      run_locally "rm -rf #{bower_directory}.tar.gz"
    else bower_mode == 'server'
      run "cd #{release_path} && bower install"
    end
    console_puts_ok
  end
end

after "deploy:update_code" do
  if use_bower
    bower.install
  end
end
