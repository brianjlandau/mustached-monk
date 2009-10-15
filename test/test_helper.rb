ENV['RACK_ENV'] = 'test'

require File.expand_path(File.join(File.dirname(__FILE__), "..", "init"))

require "rack/test"
require "contest"
require "quietbacktrace"
require 'active_support/testing/assertions'

Ohm.flush

Debugger.start
Debugger.settings[:autoeval] = true
Debugger.settings[:autolist] = 1

class Test::Unit::TestCase
  include Rack::Test::Methods
  include ActiveSupport::Testing::Assertions

  def app
    Main.new
  end
end
