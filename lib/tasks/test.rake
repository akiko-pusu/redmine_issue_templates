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

  desc 'Run rubycritic for redmine_issue_template plugin'
  begin
    require 'rubycritic/rake_task'
    RubyCritic::RakeTask.new do |t|
      t.paths = FileList['plugins/redmine_issue_templates/app']
      t.options = '-p redmine_issue_templates_critic --no-browser --mode-ci'
    end
  rescue LoadError
    puts 'rubycritic failed.'
  end
end
