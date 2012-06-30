require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'issues_controller'

# Re-raise errors caught by the controller.
class IssuesController; def rescue_action(e) raise e end; end

# Test for view hooks.
class IssuesControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
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
    @controller = IssuesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    enabled_module = EnabledModule.new
    enabled_module.project_id = 1
    enabled_module.name = 'issue_templates'
    enabled_module.save
    roles = Role.find(:all)
    roles.each {|role|
      role.permissions << :show_issue_templates
      role.remove_permission! :edit_issue_templates
      role.save
    }
    @request.session[:user_id] = 2
    @project = Project.find(1)
  end

  def test_index_without_project    
    get :index
    assert_response :success
    assert_select 'h3.template', false
  end
  
  def test_index
    get :index, :project_id => @project.id
    assert_response :success
    assert_select 'div#template_area select#issue_template', false, 
      "Action index should not contain template select pulldown."
    assert_select 'h3.template'
    assert_select "a", {:href=>"/projects/#{@project}/issue_templates/new"}, false
  end

  def test_index_with_edit_permission
    Role.find(1).add_permission! :edit_issue_templates    
    get :index, :project_id => @project.id
    assert_select 'h3.template'
    assert_select "a", {:href=>"/projects/#{@project}/issue_templates/new"}
  end
  
  def test_new
    get :new, :project_id => 1
    assert_response :success
    assert_select 'div#template_area select#issue_template'
  end
  
end