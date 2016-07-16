# To change this template, choose Tools | Templates
# and open the template in the editor.

class IssueTemplatesIssuesHook < Redmine::Hook::ViewListener
  include IssuesHelper

  def view_layouts_base_html_head(context = {})
    o = stylesheet_link_tag('issue_templates', plugin: 'redmine_issue_templates')
    if (context[:controller].class.name == 'IssuesController' &&
        context[:controller].action_name != 'index') ||
       (context[:controller].class.name == 'IssueTemplatesController') ||
       (context[:controller].class.name == 'GlobalIssueTemplatesController')
      o << javascript_include_tag('issue_templates', plugin: 'redmine_issue_templates')
    end
    o
  end

  def view_issues_form_details_top(context = {})
    action = context[:request].parameters[:action]
    project = context[:project]
    issue = context[:issue]
    return if issue.tracker_id.blank?
    project_id = project.present? ? project.id : issue.project_id
    setting = IssueTemplateSetting.find_or_create(project_id)
    copy_from = context[:request].parameters[:copy_from]
    is_triggered_by_status = triggered_by_status?(context[:request])
    return '' unless copy_from.blank?
    return '' unless (action == 'new' || action == 'update_form' || action == 'create') && !project_id.blank? && issue.id.blank?
    context[:controller].send(
      :render_to_string,
      partial: 'issue_templates/issue_select_form',
      locals: { setting: setting, issue: issue, is_triggered_by_status: is_triggered_by_status,
                project_id: project_id }
    )
  end

  render_on :view_issues_sidebar_planning_bottom, partial: 'issue_templates/issue_template_link'

  private

  def triggered_by_status?(request)
    triggered = request.parameters[:form_update_triggered_by]
    triggered ? triggered == 'issue_status_id' : false
  end
end
