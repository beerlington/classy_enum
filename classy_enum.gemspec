# -*- encoding: utf-8 -*-
require File.expand_path('../lib/classy_enum/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Peter Brown"]
  gem.email         = ["github@lette.us"]
  gem.description   = "A utility that adds class based enum functionality to ActiveRecord attributes"
  gem.summary       = "A class based enumerator utility for Ruby on Rails"
  gem.homepage      = "http://github.com/beerlington/classy_enum"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "classy_enum"
  gem.require_paths = ["lib"]
  gem.version       = ClassyEnum::VERSION

  gem.add_dependency('activerecord', '>= 3.2')

  gem.add_development_dependency('rspec', '~> 2.11.0')
  gem.add_development_dependency('sqlite3', '~> 1.3')
  gem.add_development_dependency('json', '>= 1.6')

end
