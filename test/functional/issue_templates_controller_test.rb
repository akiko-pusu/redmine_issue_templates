require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class IssueTemplatesControllerTest < Redmine::ControllerTest
  fixtures :projects, :users, :roles, :trackers, :members, :member_roles, :enabled_modules,
           :issue_templates,
           :projects_trackers

  include Redmine::I18n

  def setup
    @request.session[:user_id] = 2
    @request.env['HTTP_REFERER'] = '/'
    # Enabled Template module
    @project = Project.find(1)
    @project.enabled_modules << EnabledModule.new(name: 'issue_templates')
    @project.save!
  end

  context '#index' do
    setup do
    end

    should 'return 404 with non existing project' do
      # set non existing project
      get :index, params: { project_id: 100 }
      assert_response 404
    end

    should 'without show permission return 403' do
      # set non existing project
      Role.find(1).remove_permission! :show_issue_templates
      get :index, params: { project_id: 1 }
      assert_response 403
    end

    should 'get index with status code 200' do
      Role.find(1).add_permission! :show_issue_templates
      get :index, params: { project_id: 1 }
      assert_response :success
    end
  end

  context '#show' do
    context 'with permission' do
      setup do
        Role.find(1).add_permission! :show_issue_templates
      end

      should 'return 404 with non existing template' do
        get :show, params: { id: 100, project_id: 1 }
        assert_response 404
      end

      should 'return json hash' do
        get :load, params: {project_id: 1, id: 1}
        assert_response :success
        assert_equal 'description1', json_response['issue_template']['description']
      end

      should 'return json hash of global' do
        get :load, params: {project_id: 1, id: 1, template_type: 'global'}
        assert_response :success
        assert_equal 'global description1', json_response['global_issue_template']['description']
      end

      should 'render pulldown' do
        get :set_pulldown, params: { project_id: 1, issue_tracker_id: 1 }
        tracker = Tracker.find(1)
        assert_response :success
        assert_select "optgroup[label=#{tracker.name}]"
      end
    end
  end

  context '#new' do
    context 'with permission' do
      setup do
        Role.find(1).add_permission! :show_issue_templates
        Role.find(1).add_permission! :edit_issue_templates
      end

      should 'return new template instance when request is get' do
        get :new, params: { project_id: 1, author_id: 2 }
        assert_response :success
      end

      # do post
      should 'insert new template record when request is post' do
        num = IssueTemplate.count
        post :new, params: { issue_template: { title: 'newtitle', note: 'note',
                                               description: 'description', tracker_id: 1, enabled: 1, author_id: 3 },
                             project_id: 1 }

        assert_response :redirect # show
        assert_equal(num + 1, IssueTemplate.count)
      end

      # fail check
      should 'not be able to save if title is empty' do
        num = IssueTemplate.count

        # when title blank, validation bloks to save.
        post :new, params: { issue_template: { title: '', note: 'note',
                                               description: 'description', tracker_id: 1, enabled: 1,
                                               author_id: 1 }, project_id: 1 }

        assert_response :success
        assert_equal(num, IssueTemplate.count)
      end

      should 'preview template' do
        post :preview, params: {issue_template: {description: 'h1. Test data.'}, project_id: 1}
        assert_select 'h1', /Test data\./, @response.body.to_s
      end
    end
  end

  context '#update' do
    context 'with permission' do
      setup do
        Role.find(1).add_permission! :show_issue_templates
        Role.find(1).add_permission! :edit_issue_templates
      end

      should 'edit template when request is put' do
        put :update, params: {id: 2,
                              issue_template: {description: 'Update Test template2'},
                              project_id: 1}
        project = Project.find 1
        assert_response :redirect # show
        issue_template = IssueTemplate.find(2)
        assert_redirected_to controller: 'issue_templates',
                             action: 'show', id: issue_template.id, project_id: project
        assert_equal 'Update Test template2', issue_template.description
      end

      should 'not destroy enabled template when request is delete' do
        post :destroy, params: { id: 1, project_id: 1 }
        project = Project.find 1
        assert_redirected_to controller: 'issue_templates',
                             action: 'show', project_id: project, id: 1
        assert_match(/Only disabled template can be destroyed/, flash[:error])
      end

      should 'destroy disabled template when request is delete' do
        template = IssueTemplate.find(1)
        template.enabled = false
        template.save
        post :destroy, params: { id: 1, project_id: 1 }
        project = Project.find 1
        assert_redirected_to controller: 'issue_templates',
                             action: 'index', project_id: project
        assert_raise(ActiveRecord::RecordNotFound) { IssueTemplate.find(1) }
      end

      should 'not be able to change project id and safe attributes' do
        put :update, params: {id: 2,
                              issue_template: {description: 'Update Test template2',
                                               project_id: 2, author_id: 2 },
                              project_id: 1}
        project = Project.find 1
        assert_response :redirect # show
        issue_template = IssueTemplate.find(2)
        assert_redirected_to controller: 'issue_templates',
                             action: 'show', id: issue_template.id, project_id: project
        assert_equal 'Update Test template2', issue_template.description
        assert_equal(1, issue_template.project.id)
        assert_equal(1, issue_template.author.id)
      end
    end
  end

  context 'child project #index' do
    setup do
      @project = Project.find(3)
      @project.enabled_modules << EnabledModule.new(name: 'issue_templates')
      @project.save!

      # do as Admin
      @request.session[:user_id] = 1
    end

    should 'should get index' do
      get :index, params: { project_id: 1 }
      assert_response :success
      assert_select 'h2', text: l(:issue_template).to_s, count: 1
      assert !@response.body.match(%r{<h3>#{l(:label_inherited_templates)}</h3>})

      get :index, params: { project_id: 3 }
      assert_response :success
      assert_select 'h2', text: l(:issue_template).to_s, count: 1
      assert !@response.body.match(%r{<h3>#{l(:label_inherited_templates)}</h3>})
    end

    should 'should get index with inherit templates' do
      setting = IssueTemplateSetting.find(3)
      setting.inherit_templates = true
      setting.save!

      get :index, params: { project_id: 3 }
      assert_response :success
      assert_select 'h2', text: l(:issue_template).to_s, count: 1
    end

    should 'render pulldown with parent template' do
      setting = IssueTemplateSetting.find(3)
      setting.inherit_templates = true
      setting.save!
      tracker = Tracker.find(1)
      get :set_pulldown, params: { project_id: 3, issue_tracker_id: 1 }
      assert_select "optgroup[label='#{tracker.name}']"
      assert_select 'option[value="1"]'
      assert_select 'option[class="global"]'
    end
  end

  def json_response
    ActiveSupport::JSON.decode @response.body
  end
end
