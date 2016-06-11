require 'rake'
require 'rake/testtask'
require 'yard'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the redmine_banner plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

YARD::Rake::YardocTask.new(:yardoc) do |t|
  files = ['lib/**/*.rb', 'app/**/*.rb'] #exclude test file
  t.files = files
  t.options += ['--output-dir', './doc']
end