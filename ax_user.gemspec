$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ax_user/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ax_user"
  s.version     = AxUser::VERSION
  s.authors     = ['azimux']
  s.email       = ['azimux@gmail.com']
  s.homepage    = 'http://github.com/azimux/ax_user'
  s.summary     = 'Engine for User creation and authentication'
  s.description = 'Engine for User creation and authentication'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT_LICENSE.txt", "Rakefile", "README"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.12"

  s.add_development_dependency "sqlite3"
end
