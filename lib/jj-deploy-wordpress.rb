require 'capistrano'
require 'railsless-deploy'
require 'colored'
require 'capistrano/ext/multistage'

module JjDeploy
    module Wordpress
        def self.load_into(configuration)

            configuration.load do

                load_paths.push File.expand_path('../', __FILE__)
                load 'includes/tools'
                load 'includes/composer'
                load 'includes/slack'
                load 'includes/access'
                load 'includes/extras'
            end
        end
    end
end


if Capistrano::Configuration.instance
    JjDeploy::Wordpress.load_into(Capistrano::Configuration.instance)
end
