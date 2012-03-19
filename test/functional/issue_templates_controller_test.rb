require File.dirname(__FILE__) + '/../test_helper'

class IssueTemplatesControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :trackers, :members, :member_roles, :enabled_modules, :issue_templates
  def setup
    @controller = IssueTemplatesController.new
    @request    = ActionController::TestRequest.new
    @request.session[:user_id] = 2
    @response   = ActionController::TestResponse.new
    @request.env["HTTP_REFERER"] = '/'
    # Enabled Template module
    @project = Project.find(1)
    @project.enabled_modules << EnabledModule.new(:name => 'issue_templates')
    @project.save!
  end

  context "#index" do
    setup do
    end

    should "non existing project return 404" do
      # set non existing project
      get :index
      assert_response 404
    end

     should "without show permission return 403" do
      # set non existing project
      Role.find(1).remove_permission! :show_issue_templates
      get :index, :project_id => 1
      assert_response 403
    end       
    
    should "should get index" do
      Role.find(1).add_permission! :show_issue_templates
      get :index, :project_id => 1
      assert_response :success
      assert_template 'index'
      assert_not_nil assigns(:issue_templates)
    end
  end
  
  context "#show" do
    context "with permission" do
      setup do
        Role.find(1).add_permission! :show_issue_templates         
      end
      should "return json hash" do
        get :load, :project_id => 1, :issue_template => 1
        assert_response :success
        assert_equal "description1", json_response['description']
      end
    end
  end
  
 
  context "#new" do
    context "with permission" do
      setup do
        Role.find(1).add_permission! :show_issue_templates
        Role.find(1).add_permission! :edit_issue_templates          
      end

      should "return new template instance when request is get" do
        get :new, :project_id => 1, :author_id => 2
        assert_response :success

        template = assigns(:issue_template)
        assert_not_nil template
        assert template.title.blank?
        assert template.description.blank?
        assert template.note.blank?
        assert template.tracker.blank?
        assert_equal(2, template.author.id)
        assert_equal(1, template.project.id)
      end

      # do post
      should "insert new template record when request is post" do
        count = IssueTemplate.find(:all).length
        post :new, :issue_template => {:title => "newtitle", :note => "note", 
          :description => "description", :tracker_id => 1, :enabled => 1, :author_id => 3 
          }, :project_id => 1

        template = IssueTemplate.first(:order => 'id DESC')
        assert_response :redirect # show

        assert_equal(count + 1, IssueTemplate.find(:all).length)

        assert_not_nil template
        assert_equal("newtitle", template.title)
        assert_equal("note", template.note)
        assert_equal("description", template.description)
        assert_equal(1, template.project.id)
        assert_equal(1, template.tracker.id)
        assert_equal(2, template.author.id)
      end

      # fail check
      should "not be able to save if title is empty" do
        count = IssueTemplate.find(:all).length

        # when title blank, validation bloks to save.
        post :new, :issue_template => {:title => "", :note => "note", 
          :description => "description", :tracker_id => 1, :enabled => 1, 
          :author_id => 1 }, :project_id => 1

        assert_response :success
        assert_equal(count, IssueTemplate.find(:all).length)
      end

      should "should preview template" do
        get :preview, {:issue_template => {:description=> "h1. Test data."}}
        assert_template "common/_preview.html.erb"
        assert_select 'h1', /Test data\./, "#{@response.body}"
      end
    end
  end
    
 context "#edit" do
   context "with permission" do
      setup do
        Role.find(1).add_permission! :show_issue_templates
        Role.find(1).add_permission! :edit_issue_templates          
      end
  
      def setup     
        Role.find(1).add_permission! :show_issue_templates
        Role.find(1).add_permission! :edit_issue_templates
      end

      should "should edit template when request is post" do
        post :edit, :id => 2, 
          :issue_template => { :description => 'Update Test template2'}, 
          :project_id => 1
        project = Project.find 1
        assert_response :redirect # show
        issue_template = IssueTemplate.find(2)
        assert_redirected_to :controller => 'issue_templates', 
          :action => "show", :id => issue_template.id,  :project_id => project
        assert_equal 'Update Test template2', issue_template.description
      end

      should "should destroy template when request is delete" do
        post :destroy, :id => 1, :project_id => 1
        project = Project.find 1
        assert_redirected_to :controller => 'issue_templates', 
          :action => "index",  :project_id => project
        assert_raise(ActiveRecord::RecordNotFound) {IssueTemplate.find(1)}
      end

      should "not be able to change project id and safe attributes" do
        post :edit, :id => 2, 
          :issue_template => { :description => 'Update Test template2', 
          :project_id => 2, :author_id => 2 }, 
          :project_id => 1
        project = Project.find 1
        assert_response :redirect # show
        issue_template = IssueTemplate.find(2)
        assert_redirected_to :controller => 'issue_templates', 
          :action => "show", :id => issue_template.id,  :project_id => project
        assert_equal 'Update Test template2', issue_template.description
        assert_equal(1, issue_template.project.id)
        assert_equal(1, issue_template.author.id)     
      end
   end
  end
  
  def json_response
    ActiveSupport::JSON.decode @response.body
  end
end
