require 'yard'

namespace :redmine_issue_templates do
  desc 'Run test for redmine_issue_template plugin.'
  task default: :test

  desc 'Run test for redmine_issue_template plugin.'
  Rake::TestTask.new(:test) do |t|
    t.libs << 'lib'
    t.pattern = 'plugins/redmine_issue_templates/test/**/*_test.rb'
    t.verbose = true
  end

  desc 'Generate YARD Documentation for redmine_issue_template plugin.'
  YARD::Rake::YardocTask.new(:yardoc) do |t|
    files = ['plugins/redmine_issue_templates/lib/**/*.rb', 'plugins/redmine_issue_templates/app/**/*.rb'] # exclude test file
    t.files = files
    t.options += ['--output-dir', './redmine_issue_templates_doc']
  end
end
