# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class IssueTemplatesSettingsControllerTest < Redmine::ControllerTest
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :enabled_modules,
           :issue_templates

  def setup
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
    post :edit, params: { project_id: @project,
                          settings: { enabled: '1', help_message: 'Hoo', inherit_templates: true },
                          setting_id: 1, tab: 'issue_templates' }
    assert_response 403
  end

  def test_update_with_permission_and_non_project
    post :edit, params: { project_id: 'dummy',
                          settings: { enabled: '1', help_message: 'Hoo', inherit_templates: true },
                          setting_id: 1 }
    assert_response 404
  end

  def test_update_with_permission_and_redirect
    post :edit, params: { project_id: @project,
                          settings: { enabled: '1', help_message: 'Hoo', inherit_templates: true },
                          setting_id: 1 }
    assert_response :redirect
    assert_redirected_to controller: 'issue_templates_settings',
                         action: 'index', project_id: @project
  end

  def test_preview_template_setting
    post :preview, params: { settings: { help_message: 'h1. Preview test.',
                                         enabled: '1' },
                             project_id: @project }
    assert_select 'h1', /Preview test\./, @response.body.to_s
  end

  def test_create_template_setting
    IssueTemplateSetting.delete_all

    post :edit, params: { project_id: @project,
                          settings: { enabled: '1', help_message: 'Hoo', inherit_templates: true },
                          setting_id: 1 }
    assert_response :redirect
    assert_redirected_to controller: 'issue_templates_settings',
                         action: 'index', project_id: @project
  end
end
