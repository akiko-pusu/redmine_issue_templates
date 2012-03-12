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
  
  render_on :view_issues_form_details_top, :partial => 'issue_templates/issue_select_form'
end
