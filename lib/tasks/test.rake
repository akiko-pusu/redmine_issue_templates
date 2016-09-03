namespace :redmine_issue_templates do
  desc 'Run test for redmine_issue_template plugin.'
  task default: :test

  desc 'Run test for redmine_issue_template plugin.'
  Rake::TestTask.new(:test) do |t|
    t.libs << 'lib'
    t.pattern = 'plugins/redmine_issue_templates/test/**/*_test.rb'
    t.verbose = true
  end
end
