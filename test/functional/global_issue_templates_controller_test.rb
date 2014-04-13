require File.expand_path('../../test_helper', __FILE__)

class GlobalIssueTemplatesControllerTest < ActionController::TestCase
  fixtures :projects, :users, :trackers,
           :global_issue_templates,
           :global_issue_templates_projects

  include Redmine::I18n

  def setup
    @controller = GlobalIssueTemplatesController.new
    @request    = ActionController::TestRequest.new
    @request.session[:user_id] = 1 # Admin
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

    should "should get index" do
      get :index
      assert_response :success
      assert_template 'index'
      assert_not_nil assigns(:global_issue_templates)
    end
  end

  context "#edit" do
    context "with permission" do
      setup do
      end

      should "edit template when request is put" do
        put :edit, :id => 2,
            :global_issue_template => { :description => 'Update Test Global template2'}
        assert_response :redirect # show
        global_issue_template = GlobalIssueTemplate.find(2)
        assert_redirected_to :controller => 'global_issue_templates',
                             :action => "show", :id => global_issue_template.id
        assert_equal 'Update Test Global template2', global_issue_template.description
      end

      should "destroy template when request is delete" do
        post :destroy, :id => 2
        assert_redirected_to :controller => 'global_issue_templates',
                             :action => "index"
        assert_raise(ActiveRecord::RecordNotFound) {GlobalIssueTemplate.find(2)}
      end
     end
  end

  context "#new" do
    context "with permission" do
      setup do
      end

      should "return new global template instance when request is get" do
        get :new, :author_id => 1
        assert_response :success

        template = assigns(:global_issue_template)
        assert_not_nil template
        assert template.title.blank?
        assert template.description.blank?
        assert template.note.blank?
        assert template.tracker.blank?
        assert_equal(1, template.author.id)
      end

      # do post
      should "insert new global template record when request is post" do
        count = GlobalIssueTemplate.find(:all).length
        post :new, :global_issue_template => {:title => "Global Template newtitle for creation test", :note => "Global note for creation test",
                                       :description => "Global Template description for creation test",
                                       :tracker_id => 1, :enabled => 1, :author_id => 1
        }

        template = GlobalIssueTemplate.first(:order => 'id DESC')
        assert_response :redirect # show

        assert_equal(count + 1, GlobalIssueTemplate.find(:all).length)

        assert_not_nil template
        assert_equal("Global Template newtitle for creation test", template.title)
        assert_equal("Global note for creation test", template.note)
        assert_equal("Global Template description for creation test", template.description)
        assert_equal(1, template.tracker.id)
        assert_equal(1, template.author.id)
      end

      # fail check
      should "not be able to save if title is empty" do
        count = GlobalIssueTemplate.find(:all).length

        # when title blank, validation bloks to save.
        post :new, :global_issue_template => {:title => "", :note => "note",
                                       :description => "description", :tracker_id => 1, :enabled => 1,
                                       :author_id => 1 }

        assert_response :success
        assert_equal(count, GlobalIssueTemplate.find(:all).length)
      end

      should "preview template" do
        get :preview, {:global_issue_template => {:description=> "h1. Global Test data."}}
        assert_template "common/_preview"
        assert_select 'h1', /Global Test data\./, "#{@response.body}"
      end
    end
  end
end
