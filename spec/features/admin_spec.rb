require_relative '../spec_helper'
require_relative '../rails_helper'
require_relative '../support/login_helper'

RSpec.configure do |c|
  c.include LoginHelper
end

feature 'PluginSetting to apply Global issue templates to all the projects', js: true do
  given(:user) { FactoryBot.create(:user, :password_same_login, login: 'admin', language: 'en') }

  background(:all) do
    Redmine::Plugin.register(:redmine_issue_templates) do
      settings partial: 'settings/redmine_issue_templates',
               default: { 'apply_global_template_to_all_projects' => 'false' }
    end
  end

  background do
    # Prevent to call User.deliver_security_notification when user is created.
    allow_any_instance_of(User).to receive(:deliver_security_notification).and_return(true)

    Setting.send 'plugin_redmine_issue_templates=', 'apply_global_template_to_all_projects' => 'false'
    user.update_attribute(:admin, true)
    log_user(user.login, user.login)
    visit '/settings/plugin/redmine_issue_templates'
  end

  scenario 'Settings "apply_global_template_to_all_projects" is displayed.' do
    expect(page).to have_content('Apply Global issue templates to all the projects.')
    expect(page).to have_selector('#settings_apply_global_template_to_all_projects')
  end

  scenario 'Activate "apply_global_template_to_all_projects".' do
    expect(page).to have_unchecked_field('settings_apply_global_template_to_all_projects')
    check 'settings_apply_global_template_to_all_projects'
    click_on 'Apply'
    expect(page).to have_selector('#settings_apply_global_template_to_all_projects')
    expect(page).to have_checked_field('settings_apply_global_template_to_all_projects')
  end
end
