require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'issues_controller'

# Test for view hooks.
class IssuesControllerTest < Redmine::ControllerTest
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :issue_templates

  def setup
    User.current = nil
    enabled_module = EnabledModule.new
    enabled_module.project_id = 1
    enabled_module.name = 'issue_templates'
    enabled_module.save
    roles = Role.all
    roles.each do |role|
      role.permissions << :show_issue_templates
      role.remove_permission! :edit_issue_templates
      role.save
    end
    @request.session[:user_id] = 2
    @project = Project.find(1)
  end

  def test_index_without_project
    get :index
    assert_response :success
    assert_select 'h3', count: 0, text: I18n.t('issue_template')
  end

  def test_index
    get :index, params: { project_id: @project.id }
    assert_response :success
    assert_select 'div#template_area select#issue_template', false,
                  'Action index should not contain template select pulldown.'
    assert_select 'h3', text: I18n.t('issue_template')
    assert_select 'a', { href: "/projects/#{@project}/issue_templates/new" }, false
  end

  def test_index_with_edit_permission
    Role.find(1).add_permission! :edit_issue_templates
    get :index, params: { project_id: @project.id }
    assert_select 'h3', text: I18n.t('issue_template')
    assert_select 'a', href: "/projects/#{@project}/issue_templates/new"
  end

  def test_new
    get :new, params: { project_id: 1 }
    assert_response :success
    assert_select 'div#template_area select#issue_template'
  end

  # NOTE: When copy, template area should not be displayed.
  def test_copy
    get :new, params: { project_id: 1, copy_from: 1 }
    assert_response :success
    assert_select 'div#template_area', false
  end

  def test_new_without_project
    get :new
    assert_response :success
    assert_select 'div#template_area select#issue_template', true
  end
end
