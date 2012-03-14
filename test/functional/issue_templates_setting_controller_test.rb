require File.dirname(__FILE__) + '/../test_helper'

class IssuteTemplatesSettingControllerTest < ActionController::TestCase
  fixtures :projects, 
    :users, 
    :roles, 
    :members, 
    :member_roles, 
    :enabled_modules, 
    :issue_templates
  
  def setup
    @controller = IssueTemplatesSettingsController.new
    @response   = ActionController::TestResponse.new
    # Enabled Template module
    enabled_module = EnabledModule.new
    enabled_module.project_id = 1
    enabled_module.name = 'issue_templates'	
    enabled_module.save    
  end
  
  context "#update" do
    
    context "by member" do
      setup do
        @request.session[:user_id] = 2
      end
      
      context "without permission" do	
        should "403 post" do
          project = Project.find 1
          post :edit, :project_id => project, 
            :settings => { :enabled => "1", :help_message => "Hoo"},
            :setting_id => 1, :tab => "issue_templates"
          assert_response 403
        end
      end
      
      context "with permission" do	
        setup do
          Role.find(1).add_permission! :manage_issue_templates
        end
        
        should "should redirect post" do
          project = Project.find 1
          post :edit, :project_id => project, 
            :settings => { :enabled => "1", :help_message => "Hoo", :project_id => 2},
            :setting_id => 1, :tab => "issue_templates"
          assert_response :redirect          
          assert_redirected_to :controller => 'projects', 
            :action => "settings", :id => project, :tab => 'issue_templates'
        end
      end
    end
  end  
end


