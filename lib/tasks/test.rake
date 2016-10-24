namespace :redmine_issue_templates do
  desc 'Run test for redmine_issue_template plugin.'
  task default: :test

  desc 'Run test for redmine_issue_template plugin.'
  Rake::TestTask.new(:test) do |t|
    t.libs << 'lib'
    t.pattern = 'plugins/redmine_issue_templates/test/**/*_test.rb'
    t.verbose = true
  end

  desc 'Run spec for redmine_issue_template plugin'
  begin
    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = 'plugins/redmine_issue_templates/spec/**/*_spec.rb'
      t.rspec_opts = ['-I plugins/redmine_issue_templates/spec', '--format documentation']
    end
    task default: :spec
  rescue LoadError
    puts 'yardoc failed.'
  end
end
