# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../../../config/environment', __FILE__)

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/test/fixtures"
  config.include FactoryBot::Syntax::Methods

  config.before :suite, type: :feature do
    require 'selenium-webdriver'
    if ENV['DRIVER'] == 'headless'
      Capybara.register_driver :headless_chrome do |app|
        capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
            #
            # NOTE: When using Chrome headress, default window size is 800x600.
            # In case window size is not specified, Redmine renderes its contents with responsive mode.
            #
            chromeOptions: { args: %w[headless disable-gpu window-size=1024,768] }
        )
        Capybara::Selenium::Driver.new(
            app,
            browser: :chrome,
            desired_capabilities: capabilities
        )
      end
    else
      Capybara.register_driver :headless_chrome do |app|
        capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
            chromeOptions: { args: %w[] }
        )
        Capybara::Selenium::Driver.new(
            app,
            browser: :chrome,
            desired_capabilities: capabilities
        )
      end
    end
  end

  config.before :each, type: :feature do
    Capybara.javascript_driver = :headless_chrome
    Capybara.current_driver = :headless_chrome
  end

  config.include Capybara::DSL
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end