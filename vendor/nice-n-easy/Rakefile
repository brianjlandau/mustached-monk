require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "nice-n-easy"
    gem.summary = %Q{Sinatra HTML helpers that are nice-n-easy to use.}
    gem.description = %Q{A set of Sinatra HTML view helpers to make your life nicer and easier. Helpers for forms, links, and assets.}
    gem.email = "brian.landau@viget.com"
    gem.homepage = "http://github.com/brianjlandau/nice-n-easy"
    gem.authors = ["Brian Landau"]
    gem.add_dependency('sinatra', '~> 0.9')
    gem.add_dependency('activesupport', '~> 2.3')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'tasks/test'
require 'tasks/rdoc'

task :test => :check_dependencies
task :default => :test
