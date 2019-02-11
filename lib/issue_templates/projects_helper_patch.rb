require 'projects_helper'

module IssueTemplates
  module ProjectsHelperPatch
    def project_settings_tabs
      tabs = super
      @issue_templates_setting = IssueTemplateSetting.find_or_create(@project.id)
      action = { name: 'issue_templates',
                 controller: 'issue_templates_settings',
                 action: :show,
                 partial: 'issue_templates_settings/show', label: :project_module_issue_templates }
      tabs << action if User.current.allowed_to?(action, @project)
      tabs
    end
  end
end

ProjectsController.helper(IssueTemplates::ProjectsHelperPatch)
