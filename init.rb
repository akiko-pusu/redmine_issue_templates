require 'redmine'
require 'issue_templates_issues_hook'
require 'issue_templates_projects_helper_patch'

Redmine::Plugin.register :redmine_issue_templates do
  name 'Redmine Issue Templates plugin'
  author 'Akiko Takano'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  author_url 'http://twitter.com/akiko_pusu'
  requires_redmine :version_or_higher => '1.2.0'

  project_module :issue_templates do
    permission :edit_issue_templates, {:issue_templates => [:new, :edit, :destroy]}
    permission :show_issue_templates, {:issue_templates => [:index, :show, :load, :set_pulldown]}
    permission :manage_issue_templates, 
      {:issue_templates_settings => [:show, :edit]}, :require => :member
  end
  
  menu :project_menu, :issue_templates, { :controller => 'issue_templates', 
    :action => 'index' }, :caption => :issue_templates, 
    :param => :project_id, 
    :last => true
  
end

require 'dispatcher'
Dispatcher.to_prepare :redmine_issue_templates do
  require_dependency 'projects_helper'
  unless ProjectsHelper.included_modules.include? IssueTemplatesProjectsHelperPatch
    ProjectsHelper.send(:include, IssueTemplatesProjectsHelperPatch)  
  end
end  


