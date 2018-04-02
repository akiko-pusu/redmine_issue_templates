require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../support/login_helper')

include LoginHelper

feature 'Templates can be reorder via drag and drop', js: true do
  given(:user) { FactoryGirl.create(:user, :password_same_login, login: 'manager', language: 'en', admin: false) }
  given(:project) { create(:project_with_enabled_modules) }
  given(:tracker) { FactoryGirl.create(:tracker, :with_default_status) }
  given(:role) { FactoryGirl.create(:role, :manager_role) }
  given(:issue_priority) { FactoryGirl.create(:priority) }

  given(:first_target) { page.find('#template_table > tbody > tr:nth-child(1) > td.buttons > span') }
  given(:second_target) { page.find('#template_table > tbody > tr:nth-child(2) > td.buttons > span') }
  given(:last_target) { page.find('#template_table > tbody > tr:nth-child(4) > td.buttons > span') }

  background do
    FactoryGirl.create_list(:issue_template, 4, project_id: project.id, tracker_id: tracker.id)

    project.trackers << tracker
    assign_template_priv(role, add_permission: :show_issue_templates)
    assign_template_priv(role, add_permission: :edit_issue_templates)
    member = Member.new(project: project, user_id: user.id)
    member.member_roles << MemberRole.new(role: role)
    member.save
  end

  scenario 'Can drag and drop' do
    visit_template_list(user)
    within(:css, 'table#template_table') do
      expect(page).to have_selector('tbody > tr:nth-child(1)')
    end

    # change id: 1, 2, 3, 4 to 2, 3, 4, 1
    expect do
      first_target.drag_to(last_target)
      sleep 5
    end.to change {
             IssueTemplate.pluck(:position).to_a
           }.from([1, 2, 3, 4]).to([4, 1, 2, 3])

    # change id: 2, 3, 4, 1 to 2, 4, 3, 1
    expect do
      second_target.drag_to(last_target)
      sleep 5
    end.to change {
             IssueTemplate.pluck(:position).to_a
           }.from([4, 1, 2, 3]).to([4, 1, 3, 2])
  end

  private

  #   def visit_template_list(user)
  #     # TODO: If does not user update, authentication is failed. This is workaround.
  #     user.update_attribute(:admin, false)
  #     log_user(user.login, user.password)
  #     visit "/projects/#{project.identifier}/issue_templates"
  #   end
end
