require File.expand_path('../../../../config/environment', __FILE__)
require 'rspec/rails'
require 'simplecov'
require 'factory_girl_rails'
SimpleCov.start 'rails'

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/test/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.include FactoryGirl::Syntax::Methods
  FactoryGirl.definition_file_paths = [File.expand_path('../factories', __FILE__)]
  FactoryGirl.find_definitions
  config.before(:all) do
    FactoryGirl.reload
  end
end
