require File.expand_path('../test_helper', __dir__)

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
    @response = ActionController::TestResponse.new
    # Enabled Template module
    enabled_module = EnabledModule.new
    enabled_module.project_id = 1
    enabled_module.name = 'issue_templates'
    enabled_module.save

    # set default user to 2 (as member)
    @request.session[:user_id] = 2
    Role.find(1).add_permission! :manage_issue_templates

    @project = Project.find(1)
  end

  def test_update_without_permission
    Role.find(1).remove_permission! :manage_issue_templates
    post :edit, project_id: @project,
                settings: { enabled: '1', help_message: 'Hoo', inherit_templates: true },
                setting_id: 1, tab: 'issue_templates'
    assert_response 403
  end

  def test_update_with_permission_and_non_project
    post :edit, project_id: 'dummy',
                settings: { enabled: '1', help_message: 'Hoo', project_id: 2, inherit_templates: true },
                setting_id: 1, tab: 'issue_templates'
    assert_response 404
  end

  def test_update_with_permission_and_redirect
    post :edit, project_id: @project,
                settings: { enabled: '1', help_message: 'Hoo', project_id: 2, inherit_templates: true },
                setting_id: 1, tab: 'issue_templates'
    assert_response :redirect
    assert_redirected_to controller: 'projects',
                         action: 'settings', id: @project, tab: 'issue_templates'
  end

  def test_preview_template_setting
    post :preview, settings: { help_message: 'h1. Preview test.',
                               enabled: '1' },
                   project_id: @project
    assert_template 'common/_preview'
    assert_select 'h1', /Preview test\./, @response.body.to_s
  end
end
