require 'simplecov'
require 'simplecov-rcov'
if ENV['JENKINS'] == "true"
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
end 

# FIXME: Remove 'rails' because same issue is happened when run test on CI environment.
#    Ref. https://github.com/colszowka/simplecov/issues/82
SimpleCov.start

require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/fixtures/',
                                       [:issue_templates, :issue_template_settings,
                                        :global_issue_templates, :global_issue_templates_projects])
