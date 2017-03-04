require File.expand_path('../../../../config/environment', __FILE__)
require 'rspec/rails'
require 'simplecov'
require 'factory_girl_rails'
require 'database_cleaner'

SimpleCov.coverage_dir('coverage/redmine_issue_template_spec')
SimpleCov.start 'rails'

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/test/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.include FactoryGirl::Syntax::Methods
  FactoryGirl.definition_file_paths = [File.expand_path('../factories', __FILE__)]
  FactoryGirl.find_definitions
  config.before(:all) do
    FactoryGirl.reload
  end

  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
