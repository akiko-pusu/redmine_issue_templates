# To change this template, choose Tools | Templates
# and open the template in the editor.

class IssueTemplatesIssuesHook < Redmine::Hook::ViewListener
  include IssuesHelper
  
  def view_layouts_base_html_head(context = {})
    o = stylesheet_link_tag('issue_templates', :plugin => 'redmine_issue_templates')
    if (context[:controller].class.name == 'IssuesController' and 
      context[:controller].action_name != 'index') or 
      (context[:controller].class.name == 'IssueTemplatesController') or
      (context[:controller].class.name == 'GlobalIssueTemplatesController')
      o << javascript_include_tag('issue_templates', :plugin => 'redmine_issue_templates')
    end      
    return o
  end
  
  def view_issues_form_details_top(context={})
    action = context[:request].parameters[:action]
    project = context[:project]
    issue =  context[:issue]
    setting = IssueTemplateSetting.find_or_create(project.id)
    copy_from = context[:request].parameters[:copy_from]
    is_triggered_by_status = is_triggered_by_status(context[:request])
    return '' unless copy_from.blank?
    return '' unless (action == 'new' or action == 'update_form' or action == 'create') && !project.id.blank? && issue.id.blank?
    context[:controller].send(
      :render_to_string,
      {
        :partial => 'issue_templates/issue_select_form',
          locals: { setting: setting, issue: issue, is_triggered_by_status: is_triggered_by_status }
      }
    ) 
  end
  
  render_on :view_issues_sidebar_planning_bottom, :partial => 'issue_templates/issue_template_link'

  private
  def is_triggered_by_status(request)
    triggered = request.parameters[:form_update_triggered_by]
    triggered ? triggered == 'issue_status_id' : false
  end
end
