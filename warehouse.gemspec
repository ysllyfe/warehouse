$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "warehouse/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "warehouse"
  s.version     = Warehouse::VERSION
  s.authors     = ["john"]
  s.email       = ["john@sinfotech.cn"]
  s.homepage    = "https://github.com/sinfotech/warehouse"
  s.summary     = "Acts-as-warehouse."
  s.description = "Acts-as-warehouse. Related with 'pg','slim','rails'"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.6"
  s.add_dependency "slim"
  s.add_dependency "pg"
  s.add_dependency "aasm"

  s.add_development_dependency "sqlite3"
end
