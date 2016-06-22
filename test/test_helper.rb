require 'simplecov'
require 'simplecov-rcov'
require 'codeclimate-test-reporter'
require 'shoulda'
if ENV['JENKINS'] == 'true'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  true
else
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
      SimpleCov::Formatter::HTMLFormatter,
      CodeClimate::TestReporter::Formatter
  ]
end

CodeClimate::TestReporter.configure do |config|
  config.git_dir = "#{Dir.pwd}/plugins/redmine_issue_templates"
end

SimpleCov.start do
  add_filter do |source_file|
    # report this plugin only.
    !source_file.filename.include?('plugins/redmine_issue_templates') || !source_file.filename.end_with?('.rb')
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/fixtures/',
                                       [:issue_templates, :issue_template_settings,
                                        :global_issue_templates, :global_issue_templates_projects])
