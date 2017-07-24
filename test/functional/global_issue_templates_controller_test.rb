require File.expand_path('../../test_helper', __FILE__)

class GlobalIssueTemplatesControllerTest < Redmine::ControllerTest
  fixtures :projects, :users, :trackers,
           :global_issue_templates,
           :global_issue_templates_projects

  include Redmine::I18n

  def setup
    @request.session[:user_id] = 1 # Admin
    @request.env['HTTP_REFERER'] = '/'
    # Enabled Template module
    @project = Project.find(1)
    @project.enabled_modules << EnabledModule.new(name: 'issue_templates')
    @project.save!
  end

  context '#index' do
    setup do
    end

    should 'get index' do
      get :index
      assert_response :success
    end
  end

  context '#edit' do
    context 'with permission' do
      setup do
      end

      should 'edit template when request is put' do
        put :edit, params: { id: 2,
                             global_issue_template: { description: 'Update Test Global template2' } }
        assert_response :redirect # show
        global_issue_template = GlobalIssueTemplate.find(2)
        assert_redirected_to controller: 'global_issue_templates',
                             action: 'show', id: global_issue_template.id
        assert_equal 'Update Test Global template2', global_issue_template.description
      end

      should 'destroy template when request is delete' do
        post :destroy, params: { id: 2 }
        assert_redirected_to controller: 'global_issue_templates',
                             action: 'index'
        assert_raise(ActiveRecord::RecordNotFound) { GlobalIssueTemplate.find(2) }
      end
    end
  end

  context '#new' do
    context 'with permission' do
      setup do
      end

      should 'return new global template instance when request is get' do
        get :new
        assert_response :success
      end

      # do post
      should 'insert new global template record when request is post' do
        num = GlobalIssueTemplate.count
        post :new, params: { global_issue_template: { title: 'Global Template newtitle for creation test', note: 'Global note for creation test',
                                                      description: 'Global Template description for creation test',
                                                      tracker_id: 1, enabled: 1, author_id: 1 } }

        template = GlobalIssueTemplate.order('id DESC').first
        assert_response :redirect # show

        assert_equal(num + 1, GlobalIssueTemplate.count)

        assert_not_nil template
        assert_equal('Global Template newtitle for creation test', template.title)
        assert_equal('Global note for creation test', template.note)
        assert_equal('Global Template description for creation test', template.description)
        assert_equal(1, template.tracker.id)
        assert_equal(1, template.author.id)
      end

      # fail check
      should 'not be able to save if title is empty' do
        num = GlobalIssueTemplate.count

        # when title blank, validation bloks to save.
        post :new, params: { global_issue_template: { title: '', note: 'note',
                                                      description: 'description', tracker_id: 1, enabled: 1,
                                                      author_id: 1 } }

        assert_response :success
        assert_equal(num, GlobalIssueTemplate.count)
      end

      should 'preview template' do
        get :preview, params: { global_issue_template: { description: 'h1. Global Test data.' } }
        assert_select 'h1', /Global Test data\./, @response.body.to_s
      end
    end
  end
end
