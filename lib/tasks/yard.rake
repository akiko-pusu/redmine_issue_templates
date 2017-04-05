begin
  require 'yard'

  namespace :redmine_issue_templates do
    desc 'Generate YARD Documentation for redmine_issue_template plugin.'
    YARD::Rake::YardocTask.new(:yardoc) do |t|
      files = ['plugins/redmine_issue_templates/lib/**/*.rb', 'plugins/redmine_issue_templates/app/**/*.rb'] # exclude test file
      t.files = files
      t.options += ['--output-dir', './redmine_issue_templates_doc',
                    '--readme', 'plugins/redmine_issue_templates/README.rdoc',
                    ' - plugins/redmine_issue_templates/README.rdoc']
    end
  end
rescue LoadError
  puts 'yard not installed (gem install yard)'
  # http://yardoc.org
end
