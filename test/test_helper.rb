require 'simplecov'
require 'simplecov-rcov'
require 'codeclimate-test-reporter'
require 'shoulda'
if ENV['JENKINS'] == 'true'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
else
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      CodeClimate::TestReporter::Formatter
  ]
end

SimpleCov.start

require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/fixtures/',
                                       [:issue_templates, :issue_template_settings,
                                        :global_issue_templates, :global_issue_templates_projects])
