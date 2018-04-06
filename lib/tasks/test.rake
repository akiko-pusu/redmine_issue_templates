namespace :redmine_issue_templates do
  desc 'Run test for redmine_issue_template plugin.'
  task :test do |task_name|
    next unless ENV['RAILS_ENV'] == 'test' && task_name.name == 'redmine_issue_templates:test'
  end

  Rake::TestTask.new(:test) do |t|
    t.libs << 'lib'
    t.pattern = 'plugins/redmine_issue_templates/test/**/*_test.rb'
    t.verbose = false
    t.warning = false
  end

  desc 'Run spec for redmine_issue_template plugin'
  task :spec do |task_name|
    next unless ENV['RAILS_ENV'] == 'test' && task_name.name == 'redmine_issue_templates:spec'
    begin
      require 'rspec/core'
      path = 'plugins/redmine_issue_templates/spec/'
      options = ['-I plugins/redmine_issue_templates/spec']
      options << '--format'
      options << 'documentation'
      options << path
      RSpec::Core::Runner.run(options)
    rescue LoadError => ex
      puts "This task should be called only for redmine issue template spec. #{ex.message}"
    end
  end
end
