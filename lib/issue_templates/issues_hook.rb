# To change this template, choose Tools | Templates
# and open the template in the editor.
module IssueTemplates
  class IssuesHook < Redmine::Hook::ViewListener
    include IssuesHelper

    CONTROLLERS = %(
      'IssuesController' 'IssueTemplatesController' 'ProjectsController'
      'GlobalIssueTemplatesController' 'SettingsController'
    ).freeze

    ACTIONS = %('new' 'update_form' 'create', 'show').freeze

    def view_layouts_base_html_head(context = {})
      o = stylesheet_link_tag('issue_templates', plugin: 'redmine_issue_templates')
      if need_template_js?(context[:controller])
        o << javascript_include_tag('issue_templates', plugin: 'redmine_issue_templates')
      end
      o
    end

    def view_issues_form_details_top(context = {})
      issue = context[:issue]
      parameters = context[:request].parameters
      return if existing_issue?(issue)
      return if copied_issue?(parameters)

      project = context[:project]
      project_id = project.present? ? project.id : issue.project_id
      return unless create_action?(parameters[:action]) && project_id.present?

      is_triggered_by_status = triggered_by_status?(parameters)
      context[:controller].send(
        :render_to_string,
        partial: 'issue_templates/issue_select_form',
        locals: { setting: setting(project_id), issue: issue, is_triggered_by_status: is_triggered_by_status,
                  project_id: project_id }
      )
    end

    render_on :view_issues_sidebar_planning_bottom, partial: 'issue_templates/issue_template_link'

    private

    def triggered_by_status?(parameters)
      triggered = parameters[:form_update_triggered_by]
      triggered ? triggered == 'issue_status_id' : false
    end

    def existing_issue?(issue)
      issue.id.present? || issue.tracker_id.blank?
    end

    def copied_issue?(parameters)
      copy_from = parameters[:copy_from]
      copy_from.present?
    end

    def create_action?(action)
      ACTIONS.include?(action)
    end

    def setting(project_id)
      IssueTemplateSetting.find_or_create(project_id)
    end

    def need_template_js?(controller)
      CONTROLLERS.include?(controller.class.name)
    end
  end
end
