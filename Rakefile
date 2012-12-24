require 'rake'
require 'rake/testtask'
require 'rdoc/task'

desc 'Default: run unit tests.'
task :default => :rcov

require 'rcov/rcovtask'

REDMINE_ROOT = File.expand_path(File.dirname(__FILE__) + '/../../../')

Rcov::RcovTask.new(:rcov) do |t|
 t.rcov_opts << ["--rails", "--sort=coverage", "--exclude '#{REDMINE_ROOT}'"]
 t.pattern = 'test/**/*_test.rb'
 t.output_dir = 'coverage'
 t.verbose = true
end

desc 'Generate documentation for the redmine_issue_templates plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Redmine Issue Templates'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('app/**/*.rb')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options = ["--charset", "utf-8"] 
end
