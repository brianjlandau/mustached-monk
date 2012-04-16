ENV['RACK_ENV'] = 'test'

require File.expand_path(File.join(File.dirname(__FILE__), "..", "init"))

require 'rspec/autorun'
require 'capybara/rspec'

Capybara.configure do |config|
  config.app = Main.new
  config.asset_root = File.join(ROOT_DIR, 'public')
  config.save_and_open_page_path = File.join(ROOT_DIR, 'tmp/capybara')
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ROOT_DIR, "spec/support/**/*.rb")].each {|f| require f}

Ohm.flush

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
end
