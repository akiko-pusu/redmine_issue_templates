require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'projects_controller'

class ProjectsControllerTest < Redmine::ControllerTest
  fixtures :projects, :users, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules
  def setup
    # as project admin
    @request.session[:user_id] = 2
    Role.find(1).add_permission! :manage_issue_templates
    # Enabled Template module
    @project = Project.find(1)
    @project.enabled_modules << EnabledModule.new(name: 'issue_templates')
    @project.save!
  end

  def test_settings
    get :settings, params: { id: 1 }
    assert_response :success
    assert_select 'a#tab-issue_templates'
  end
end
