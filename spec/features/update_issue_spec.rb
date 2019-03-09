require_relative '../spec_helper'
require_relative '../rails_helper'
require_relative '../support/login_helper'

RSpec.configure do |c|
  c.include LoginHelper
end

feature 'Update issue', js: true do
  background(:all) do
    Redmine::Plugin.register(:redmine_issue_templates) do
      settings partial: 'settings/redmine_issue_templates',
               default: { 'apply_global_template_to_all_projects' => 'false', 'apply_template_when_edit_issue': 'true' }
    end

    given(:user) { FactoryBot.create(:user, :password_same_login, login: 'manager', language: 'en', admin: false) }
    given(:project) { create(:project_with_enabled_modules) }
    given(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
    given(:role) { FactoryBot.create(:role, :manager_role) }
    given(:issue_priority) { FactoryBot.create(:priority) }
    given(:status) { IssueStatus.create(name: 'open', is_closed: false) }
  end

  background do
    FactoryBot.create_list(:issue_template, 2, project_id: project.id, tracker_id: tracker.id)

    project.trackers << tracker
    assign_template_priv(role, add_permission: :show_issue_templates)
    member = Member.new(project: project, user_id: user.id)
    member.member_roles << MemberRole.new(role: role)
    member.save

    issue = Issue.create(project_id: project.id, tracker_id: tracker.id,
                         author_id: user.id,
                         status_id: 1, priority: issue_priority,
                         subject: 'test_create',
                         issue_status: status.id,
                         description: 'IssueTest#test_create')
    issue.save
  end

  private

  def visit_update_issue(user)
    user.update_attribute(:admin, false)
    log_user(user.login, user.password)
    issue = Issue.last
    visit "/projects/#{project.identifier}/issues/#{issue.id}"
    page.find('a.icon.icon-edit:first-of-types').click
    expect(page).to have_selector('div#template_area select#issue_template')
  end
end
