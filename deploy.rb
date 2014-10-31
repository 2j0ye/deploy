require 'railsless-deploy'
require 'colored'

# logger.level = Capistrano::Logger::MAX_LEVEL
logger.level = Capistrano::Logger::IMPORTANT

set :deploy_dir, "#{File.dirname(__FILE__)}"
set :project_root, "#{deploy_dir}/.."

load deploy_dir + '/includes/tools'
load deploy_dir + '/includes/tasks'

# external config
load project_root + '/config/banana'

require 'capistrano/ext/multistage'
