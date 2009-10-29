ROOT_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? ROOT_DIR

require "rubygems"

begin
  require "vendor/dependencies/lib/dependencies"
rescue LoadError
  require "dependencies"
end

require "monk/glue"
require 'rack/static'
require 'rack/cache'
require 'initializers/rack/etag'
require 'active_support'
require 'redis'
require "redis-store"
require 'ohm'
require 'mustache/sinatra'
require 'sinatra/nice_easy_helpers'


class Main < Monk::Glue
  set :app_file, __FILE__
  
  use Rack::Session::Cookie
  use Rack::Static, :urls => ["/images", "/js", "/styles"], :root => "public"
  use Rack::Cache,
    :verbose     => true,
    :metastore   => 'redis://localhost:6379/2',
    :entitystore => 'redis://localhost:6379/3'
  use Rack::ETag
  
  register Mustache::Sinatra
  set :views, root_path('app', 'templates')
  set :mustaches, root_path('app', 'views')
  helpers Sinatra::NiceEasyHelpers
  
  configure do
    Ohm.connect(settings(:redis) || {})
    
    # Load all application files.
    Dir[root_path("app/**/*.rb")].each do |file|
      require file
    end
    
    mustache_helpers Sinatra::NiceEasyHelpers
    Main::Helpers.constants.each do |const_name|
      if Main::Helpers.const_get(const_name).instance_of?(Module)
        mustache_helpers Main::Helpers.const_get(const_name)
      end
    end
  end  
end

Main.run! if Main.run?
