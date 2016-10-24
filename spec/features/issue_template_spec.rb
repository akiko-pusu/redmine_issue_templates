require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

feature 'Access Redmine top page', js: true do
  #
  # TODO: Change not to use Redmine's fixture but to use Factory...
  #
  fixtures :projects,
           :users, :email_addresses,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers

  context 'When anonymous ' do
    scenario 'Link to Global issue template is not displayed.' do
      visit '/admin'
      expect(page).not_to have_selector('#admin-menu > ul > li > a.redmine-issue-templates')
    end
  end

  context 'When Administrator' do
    background do
      log_user('admin', 'admin')
      visit '/admin'
    end

    scenario 'Link to Global issue template is displayed.' do
      expect(page).to have_selector('#admin-menu > ul > li > a.redmine-issue-templates')
    end
  end

  def log_user(login, password)
    visit '/my/page'
    assert_equal '/login', current_path
    within('#login-form form') do
      fill_in 'username', with: login
      fill_in 'password', with: password
      find('input[name=login]').click
      page.save_screenshot('capture/issues.png', full: true)
    end
  end
end
