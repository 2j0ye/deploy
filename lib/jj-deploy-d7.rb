require 'capistrano'
require 'railsless-deploy'
require 'colored'
require 'capistrano/ext/multistage'

module JjDeploy
    module D7
        def self.load_into(configuration)

            configuration.load do
                load_paths.push File.expand_path('../', __FILE__)
                load 'includes/tools'
                load 'includes/composer'
                load 'includes/access'
                load 'includes/drush'
                load 'includes/drupal'
                load 'includes/bower'
            end
        end
    end
end


if Capistrano::Configuration.instance
    JjDeploy::D7.load_into(Capistrano::Configuration.instance)
end
