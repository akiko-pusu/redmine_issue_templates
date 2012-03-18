# To change this template, choose Tools | Templates
# and open the template in the editor.

class IssueTemplatesIssuesHook < Redmine::Hook::ViewListener
  include IssuesHelper
  
  def view_layouts_base_html_head(context = {})
    o = stylesheet_link_tag('issue_templates', :plugin => 'redmine_issue_templates')
    if context[:controller].class.name == 'IssuesController' and 
      context[:controller].action_name != 'index'
      o << javascript_include_tag('issue_templates', :plugin => 'redmine_issue_templates')
    end      
    return o
  end
  
  def view_issues_form_details_top(context={})
    action = context[:request].parameters[:action]
    project_id = context[:request].parameters[:project_id]

    if (action != 'new' && action != 'create') || !project_id then
      return ''
    end
    context[:controller].send(
      :render_to_string,
      {
        :partial => 'issue_templates/issue_select_form'
      }
    ) 
  end
end
