require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules
  def setup
    @controller = ProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    # as project admin
    @request.session[:user_id] = 2
    Role.find(1).add_permission! :manage_issue_templates
    # Enabled Template module
    @project = Project.find(1)
    @project.enabled_modules << EnabledModule.new(:name => 'issue_templates')
    @project.save!    
  end
  
  def test_settings
    get :settings, :id => 1
    assert_response :success
    assert_template 'settings'
    assert_select 'a#tab-issue_templates'
  end  
end
