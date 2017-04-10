require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../support/login_helper')

include LoginHelper

feature 'PluginSetting to apply Global issue templates to all the projects', js: true do
  given(:user) { FactoryGirl.create(:user, :password_same_login, login: 'admin', language: 'en') }

  background(:all) do
    Redmine::Plugin.register(:redmine_issue_templates) do
      settings partial: 'settings/redmine_issue_templates',
               default: { 'apply_global_template_to_all_projects' => 'false' }
    end
  end

  background do
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
