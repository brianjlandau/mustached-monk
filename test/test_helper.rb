ENV['RACK_ENV'] = 'test'

require File.expand_path(File.join(File.dirname(__FILE__), "..", "init"))

require "rack/test"
require "contest"
require "quietbacktrace"

class Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Main.new
  end
end
