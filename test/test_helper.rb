begin
  require 'simplecov'
  require 'simplecov-rcov'
rescue LoadError => ex
  puts <<-"EOS"
  This test should be called only for redmine issue template test.
    Test exit with LoadError --  #{ex.message}
  Please move redmine_issue_templates/Gemfile.local to redmine_issue_templates/Gemfile
  and run bundle install if you want to to run tests.
  EOS
  exit
end

if ENV['JENKINS'] == 'true'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  true
else
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter])
end

SimpleCov.coverage_dir('coverage/redmine_issue_templates_test')
SimpleCov.start do
  add_filter do |source_file|
    # report this plugin only.
    !source_file.filename.include?('plugins/redmine_issue_templates') || !source_file.filename.end_with?('.rb')
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/',
                                         %i[issue_templates issue_template_settings
                                            global_issue_templates global_issue_templates_projects])
