require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "classy_enum"
    gem.summary = %Q{A class based enumerator utility for Ruby on Rails}
    gem.description = %Q{A utility that adds class based enum functionaltiy to ActiveRecord attributes}
    gem.email = "github@lette.us"
    gem.homepage = "http://github.com/beerlington/classy_enum"
    gem.authors = ["Peter Brown"]
    gem.add_development_dependency "rspec", "~> 2.0"
    gem.add_dependency "activerecord", "~> 3.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "thegem #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
