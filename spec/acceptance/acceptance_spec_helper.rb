require 'spec_helper'
require 'capybara/session'

include Warden::Test::Helpers
Warden.test_mode!


RSpec.configure do |config|
  config.before(:each) do
    Capybara.reset_sessions!
  end

  config.after(:each) do
    Warden.test_reset!
  end
end

def sign_in(user=nil, scope=:user)
  user ||= create(scope)
  login_as user, scope: scope
end
