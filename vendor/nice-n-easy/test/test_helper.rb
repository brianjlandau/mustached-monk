require 'test/unit'
require 'rubygems'
require 'contest'
require 'ruby-debug'
Debugger.start
Debugger.settings[:autoeval] = true

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sinatra/nice_easy_helpers'
require 'tag_matcher'

class Test::Unit::TestCase
  include TagMatchingAssertions
end
