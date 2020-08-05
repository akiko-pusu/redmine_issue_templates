require File.expand_path('../test_helper', __dir__)
require 'minitest/autorun'

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

  def test_get_index
    get :index
    assert_response :success
  end

  def test_update_template
    put :update, params: { id: 2, global_issue_template:
      { description: 'Update Test Global template2' } }
    assert_response :redirect # show
    global_issue_template = GlobalIssueTemplate.find(2)
    assert_redirected_to controller: 'global_issue_templates',
                         action: 'show', id: global_issue_template.id
    assert_equal 'Update Test Global template2', global_issue_template.description
  end

  def test_update_template_with_empty_title
    put :update, params: { id: 2, global_issue_template:
      { title: '' } }
    assert_response :success
    global_issue_template = GlobalIssueTemplate.find(2)
    assert_not_equal '', global_issue_template.title

    # render :show
    assert_select 'h2.global_issue_template', "#{l(:global_issue_templates)}: ##{global_issue_template.id}"
    # Error message should be displayed.
    assert_select 'div#errorExplanation', { count: 1, text: /Title cannot be blank/ }, @response.body.to_s
  end

  def test_destroy_template
    post :destroy, params: { id: 2 }
    assert_redirected_to controller: 'global_issue_templates',
                         action: 'index'
    assert_raise(ActiveRecord::RecordNotFound) { GlobalIssueTemplate.find(2) }
  end

  def test_new_template
    get :new
    assert_response :success
  end

  def test_create_template
    num = GlobalIssueTemplate.count
    post :create, params: { global_issue_template: { title: 'Global Template newtitle for creation test', note: 'Global note for creation test',
                                                     description: 'Global Template description for creation test',
                                                     tracker_id: 1, enabled: 1, author_id: 1 } }

    template = GlobalIssueTemplate.order('id DESC').first
    assert_response :redirect

    assert_equal(num + 1, GlobalIssueTemplate.count)

    assert_not_nil template
    assert_equal('Global Template newtitle for creation test', template.title)
    assert_equal('Global note for creation test', template.note)
    assert_equal('Global Template description for creation test', template.description)
    assert_equal(1, template.tracker.id)
    assert_equal(1, template.author.id)
  end

  def test_create_template_fail
    num = GlobalIssueTemplate.count

    # when title blank, validation bloks to save.
    post :create, params: { global_issue_template: { title: '', note: 'note',
                                                     description: 'description', tracker_id: 1, enabled: 1,
                                                     author_id: 1 } }

    assert_response :success
    assert_equal(num, GlobalIssueTemplate.count)

    # render :new
    assert_select 'h2', text: "#{l(:issue_templates)} / #{l(:button_add)}"
    # Error message should be displayed.
    assert_select 'div#errorExplanation', { count: 1, text: /Title cannot be blank/ }, @response.body.to_s
  end

  def test_preview_template
    get :preview, params: { global_issue_template: { description: 'h1. Global Test data.' } }
    assert_select 'h1', /Global Test data\./, @response.body.to_s
  end
end
