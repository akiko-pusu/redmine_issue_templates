require 'redmine'
require 'issue_templates_issues_hook'
require 'issue_templates_projects_helper_patch'

Redmine::Plugin.register :redmine_issue_templates do
  name 'Redmine Issue Templates plugin'
  author 'Akiko Takano'
  description 'Plugin to generate and use issue templates for each project to assist issue creation.'
  version '0.0.2.1'
  author_url 'http://twitter.com/akiko_pusu'
  requires_redmine :version_or_higher => '1.3.0'
  url 'https://bitbucket.org/akiko_pusu/redmine_issue_templates'

  project_module :issue_templates do
    permission :edit_issue_templates, {:issue_templates => [:new, :edit, :destroy]}
    permission :show_issue_templates, {:issue_templates => [:index, :show, :load, :set_pulldown]}
    permission :manage_issue_templates, 
      {:issue_templates_settings => [:show, :edit]}, :require => :member
  end
  
end

require 'dispatcher'
Dispatcher.to_prepare :redmine_issue_templates do
  require_dependency 'projects_helper'
  unless ProjectsHelper.included_modules.include? IssueTemplatesProjectsHelperPatch
    ProjectsHelper.send(:include, IssueTemplatesProjectsHelperPatch)  
  end
end  


