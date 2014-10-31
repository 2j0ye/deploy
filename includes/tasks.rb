# after trigger
after 'deploy', 'deploy:cleanup'
after 'deploy:cold', 'deploy:cleanup'
after 'deploy:build', 'deploy:setup', 'deploy:cold'

namespace :deploy do

  desc "Create files dir for each domain"
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, releases_path, shared_path]
    domains.each do |domain|
      dirs += [shared_path + "/#{domain}/files"]
    end
    dirs += %w(system).map { |d| File.join(shared_path, d) }
    run "umask 02 && mkdir -p #{dirs.join(' ')}"
  end

  desc "Complete Site setup (setup + deploy:cold + files upload + database upload"
    task :build do
  end

  desc "Group writable permission"
  task :finalize_update, :except => { :no_release => true } do
    "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
  end
end
