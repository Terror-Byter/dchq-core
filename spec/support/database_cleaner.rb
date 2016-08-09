RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before :each do
    DatabaseCleaner.strategy = :transaction
  end

  config.before :each, :js => true do
    DatabaseCleaner.strategy = :truncation, {:pre_count => true}
  end

  config.before :each do
    DatabaseCleaner.start
    ActionMailer::Base.deliveries.clear
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
