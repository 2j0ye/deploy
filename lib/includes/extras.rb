set :use_sound, false
set :notify_dashboard, true
set :lab_deploy_url, "http://deploys.dashboard.dev.scoua.de/api/v1/deploys"


namespace :extras do
  task :valkyrie do
  	desc "Play extra song when deploy is finished"
    run_locally "afplay deploy/files/valkyrie.aiff";
  end

  task :notify_dashboard do
  	desc "Tell lab deploys dashaboad a new release has been deployed"
    if lab_deploy_url != ''
      console_pretty_print '--> Lab Deploy'
      uri = URI.parse("#{lab_deploy_url}")
      data = {
        "project_name" => "#{application}",
        # "date" => Time.now.to_s,
        "deployer_name" => ENV['USER'] || ENV['USERNAME'] || 'n/a',
        "environment" => "#{stage}",
        "version" => "#{branch}",
      }
      data = JSON.parse(data.to_json)
      postData = Net::HTTP.post_form(uri, data)
      console_puts_ok
    end
  end
end


after "deploy" do
  if use_sound
    extras.valkyrie
  end
  if notify_dashboard
    extras.notify_dashboard
  end
end
