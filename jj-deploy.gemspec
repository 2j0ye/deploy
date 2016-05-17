Gem::Specification.new do |s|
  s.name        = 'jj-deploy'
  s.version     = '1.0'
  s.date        = '2016-05-17'
  s.summary     = "jj deploy"
  s.description = "capistrano receipes we used to include in our projects"
  s.authors     = ["Jjoye"]
  s.email       = 'julien.joye@gmail.com'
  s.files        = Dir.glob("{lib}/**/*")
  s.require_paths = ["lib"]
  s.license     = 'Not Free.'

  s.add_dependency 'capistrano', ">= 2.13.5","<= 2.16.0"
  s.add_dependency 'colored', ">= 1.2.0"
  s.add_dependency 'ruby-progressbar', '1.4.1'
  s.add_dependency 'railsless-deploy'
  s.add_dependency 'term-ansicolor'

end
