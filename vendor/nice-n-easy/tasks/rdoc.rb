begin
  require 'rake/rdoctask'
  require 'sdoc'
  require File.join(File.dirname(__FILE__), 'vendor/sdoc-helpers/markdown')
  require File.join(File.dirname(__FILE__), 'vendor/sdoc-helpers/pages')
  
  Rake::RDocTask.new do |rdoc|
    version = File.exist?('VERSION') ? File.read('VERSION') : ""

    rdoc.rdoc_dir = 'docs'
    rdoc.title = "Nice-n-Easy #{version} Documentation"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('LICENSE')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.main = 'README.md'
    rdoc.template = 'direct'
    rdoc.options << '--fmt' << 'shtml'
  end
rescue LoadError
  puts "sdoc RDoc tasks not loaded. Please intall sdoc."
end