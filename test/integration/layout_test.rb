require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class LayoutTest < Redmine::IntegrationTest
  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :enabled_modules,
           :workflows,
           :issue_templates

  def test_issue_template_not_visible_when_module_off
    # module -> disabled
    log_user('admin', 'admin')
    post '/projects/ecookbook/modules',
         params: { enabled_module_names: ['issue_tracking'], commit: 'Save', id: 'ecookbook' }

    get '/projects/ecookbook/issues'
    assert_response :success
    assert_select 'h3', count: 0, text: I18n.t('issue_template')

    get '/projects/ecookbook/issues/new'
    assert_select 'div#template_area select#issue_template', 0
  end

  def test_issue_template_visible_when_module_on
    # module -> enabled
    log_user('admin', 'admin')
    post '/projects/ecookbook/modules',
         params: { enabled_module_names: %w[issue_tracking issue_templates],
                   commit: 'Save', id: 'ecookbook' }

    get '/projects/ecookbook/issues'
    assert_response :success
  end
end
