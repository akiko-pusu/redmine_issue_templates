require_dependency 'projects_helper'

module IssueTemplatesProjectsHelperPatch
  def self.included(base)
    base.send(:include, ProjectsHelperMethodsIssueTemplates)
    base.class_eval do
      alias_method_chain :project_settings_tabs, :issue_templates
    end
  end
end

module ProjectsHelperMethodsIssueTemplates
  # Append tab for issue templates to project settings tabs.
  def project_settings_tabs_with_issue_templates
    tabs = project_settings_tabs_without_issue_templates
    action = {:name => 'issue_templates', 
      :controller => 'issue_templates_settings',
      :action => :show, 
      :partial => 'issue_templates_settings/show', :label => :issue_templates}
    tabs << action if User.current.allowed_to?(action, @project)
    tabs
  end
end



