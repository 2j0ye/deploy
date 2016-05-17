require "net/http"
require 'json'

set :slack_url, ''

after "deploy", "slack:release"

namespace :slack do
  desc "Tell Slack a new release has been deployed"
  task :release do
    if slack_url != ''
      console_pretty_print '--> Slack ('+slack_url+')'

      uri = URI.parse(slack_url)

      postData = Net::HTTP.post_form(uri, {
        "payload" => JSON.generate({
          # Default values defined in the webhook config
          # "username" => "Deploy Bot",
          # "icon_emoji" => ":white_check_mark:",
          "text" => "#{application} - #{stage} succesfully deployed on branch #{branch}",
          "attachments" => [{
            # "fallback" => "#{application} - #{stage} succesfully deployed on branch #{branch}",
            # "text" => "#{application} - #{stage} succesfully deployed",
            # "pretext" => "Optional text that should appear above the formatted data",
            "color" => "good",
            "fields" => [
              {
                "title" => "Deployer",
                "value" => ENV['USER'] || ENV['USERNAME'] || 'n/a',
                "short" => true
              },
              {
                "title" => "Server",
                "value" => "#{domain}",
                "short" => true
              },
              {
                "title" => "Application",
                "value" => "#{application}",
                "short" => true
              },
              {
                "title" => "Environment",
                "value" => "#{stage}",
                "short" => true
              },
              {
                "title" => "Branch",
                "value" => "#{branch}",
                "short" => true
              },
              {
                "title" => "Date",
                "value" => Time.now.to_s,
                "short" => true
              },
            ]
          }]
        }),
      })
      console_puts_ok
    end
  end
end
