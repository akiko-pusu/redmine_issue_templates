# To change this template, choose Tools | Templates
# and open the template in the editor.
module IssueTemplates
  class IssuesHook < Redmine::Hook::ViewListener
    include IssuesHelper

    CONTROLLERS = %(
      'IssuesController' 'IssueTemplatesController' 'ProjectsController' 'IssueTemplatesSettingsController'
      'GlobalIssueTemplatesController' 'SettingsController' 'NoteTemplatesController'
      'GlobalNoteTemplatesController'
    ).freeze

    ACTIONS = %('new' 'update_form' 'create', 'show').freeze

    def view_layouts_base_html_head(context = {})
      o = stylesheet_link_tag('issue_templates', plugin: 'redmine_issue_templates')
      o << javascript_include_tag('issue_templates', plugin: 'redmine_issue_templates') if need_template_js?(context[:controller])
      o
    end

    def view_issues_form_details_top(context = {})
      issue = context[:issue]
      parameters = context[:request].parameters
      return if existing_issue?(issue)
      return if copied_issue?(parameters)

      project = context[:project]
      project_id = issue.project_id.present? ? issue.project_id : project.id
      return unless create_action?(parameters[:action]) && project_id.present?

      context[:controller].send(
        :render_to_string,
        partial: 'issue_templates/issue_select_form',
        locals: locals_params(issue, project_id, parameters[:form_update_triggered_by])
      )
    end

    render_on :view_issues_sidebar_planning_bottom, partial: 'issue_templates/issue_template_link'

    private

    def existing_issue?(issue)
      return false if apply_template_when_edit_issue?

      issue.id.present? || issue.tracker_id.blank?
    end

    def copied_issue?(parameters)
      return false if apply_template_when_edit_issue?

      copy_from = parameters[:copy_from]
      copy_from.present?
    end

    def create_action?(action)
      return true if apply_template_when_edit_issue?

      ACTIONS.include?(action)
    end

    def setting(project_id)
      IssueTemplateSetting.find_or_create(project_id)
    end

    def need_template_js?(controller)
      CONTROLLERS.include?(controller.class.name)
    end

    def plugin_setting
      Setting.plugin_redmine_issue_templates
    end

    def apply_all_projects?
      plugin_setting['apply_global_template_to_all_projects'].to_s == 'true'
    end

    def apply_template_when_edit_issue?
      plugin_setting['apply_template_when_edit_issue'].to_s == 'true'
    end

    def locals_params(issue, project_id, is_triggered_by)
      { setting: setting(project_id),
        issue: issue,
        is_triggered_by: is_triggered_by,
        project_id: project_id,
        pulldown_url: pulldown_url(issue, project_id, is_triggered_by) }
    end

    def pulldown_url(issue, project_id, is_triggered_by)
      pulldown_url = if issue.try(:id).present?
                       url_for(controller: 'issue_templates',
                               action: 'set_pulldown', project_id: project_id, is_triggered_by: is_triggered_by,
                               is_update_issue: issue.try(:id).present?)
                     else
                       url_for(controller: 'issue_templates',
                               action: 'set_pulldown', project_id: project_id, is_triggered_by: is_triggered_by)
                     end
      pulldown_url
    end
  end
end
