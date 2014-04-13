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
    project_id = context[:request].parameters[:project_id]
    issue_id =  context[:request].parameters[:id]

    return '' unless (action == 'new' or action == 'update_form' or action == 'create') && !project_id.blank? && issue_id.blank?
    context[:controller].send(
      :render_to_string,
      {
        :partial => 'issue_templates/issue_select_form'
      }
    ) 
  end
  
  render_on :view_issues_sidebar_planning_bottom, :partial => 'issue_templates/issue_template_link'
end
