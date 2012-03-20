require File.expand_path('../../test_helper', __FILE__)
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < ActionController::TestCase
#  fixtures :projects, :versions, :users, :roles, :members, :member_roles, :issues, :journals, :journal_details,
#           :trackers, :projects_trackers, :issue_statuses, :enabled_modules, :enumerations, :boards, :messages,
#           :attachments, :custom_fields, :custom_values, :time_entries
  fixtures :projects, :users, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules
  def setup
    @controller = ProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    # as project admin
    @request.session[:user_id] = 2
    # Enabled Template module
    enabled_module = EnabledModule.new
    enabled_module.project_id = 1
    enabled_module.name = 'issue_templates'	
    enabled_module.save     
  end
  
  def test_settings
    get :settings, :id => 1
    assert_response :success
    assert_template 'settings'
    assert_select 'li a#tab-issue_templates'
  end  
end
