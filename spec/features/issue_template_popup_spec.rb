require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../support/login_helper')

include LoginHelper

feature 'Confirm dialog before overwrite description', js: true do
  background(:all) do
    Redmine::Plugin.register(:redmine_issue_templates) do
      settings partial: 'settings/redmine_issue_templates',
               default: { 'apply_global_template_to_all_projects' => 'false' }
    end
  end

  given(:user) { FactoryGirl.create(:user, :password_same_login, login: 'manager', language: 'en', admin: false) }
  given(:project) { create(:project_with_enabled_modules) }
  given(:tracker) { FactoryGirl.create(:tracker, :with_default_status) }
  given(:role) { FactoryGirl.create(:role, :manager_role) }
  given(:issue_priority) { FactoryGirl.create(:priority) }
  given(:first_target) { page.find('#issue_template > optgroup > option:nth-child(1)') }
  given(:second_target) { page.find('#issue_template > optgroup > option:nth-child(2)') }
  given(:issue_subject) { page.find('#issue_subject') }
  given(:issue_description) { page.find('#issue_description') }
  given(:first_template) { IssueTemplate.first }
  given(:second_template) { IssueTemplate.second }

  background do
    FactoryGirl.create_list(:issue_template, 2, project_id: project.id, tracker_id: tracker.id)

    project.trackers << tracker
    assign_template_priv(role, add_permission: :show_issue_templates)
    member = Member.new(project: project, user_id: user.id)
    member.member_roles << MemberRole.new(role: role)
    member.save
  end

  scenario 'Template pulldown is shown when new issue.' do
    visit_new_issue(user)
    expect(page).to have_selector('div#template_area select#issue_template')
    expect(issue_description.value).to eq ''
    expect(issue_subject.value).to eq ''
  end

  scenario 'Select template and content is updated' do
    visit_new_issue(user)
    first_target.select_option
    wait_for_ajax
    expect(issue_description.value).not_to eq ''
    expect(issue_description.value).to eq first_template.description
    expect(issue_subject.value).to eq first_template.issue_title
  end

  context 'Has default template' do
    before do
      first_template.is_default = true
      first_template.save
    end

    context 'Overwite option is not activated' do
      scenario 'Template pulldown is shown when new issue and default is loaded.' do
        visit_new_issue(user)
        wait_for_ajax
        expect(page).to have_selector('div#template_area select#issue_template')
        expect(issue_description.value).not_to eq ''
        expect(issue_subject.value).not_to eq ''
        expect(issue_description.value).to eq first_template.description
        expect(issue_subject.value).to eq first_template.issue_title
      end

      scenario 'Text appended.' do
        visit_new_issue(user)
        wait_for_ajax
        expect(page).to have_selector('div#template_area select#issue_template')
        second_target.select_option
        wait_for_ajax
        expect(page).not_to have_selector('#issue_template_confirm_to_replace_dialog')
        expect(issue_description.value).not_to eq first_template.description
        expect(issue_subject.value).not_to eq first_template.issue_title
        expect(issue_subject.value).to eq "#{first_template.issue_title} #{second_template.issue_title}"
        expect(issue_description.value).to eq "#{first_template.description}\n\n#{second_template.description}"
      end

      context 'Overwite option is activated' do
        before do
          setting = IssueTemplateSetting.find_or_create(project.id)
          setting.update_attribute(:should_replaced, true)
        end
        scenario 'Conform window apperead.' do
          visit_new_issue(user)
          expect(page).to have_selector('div#template_area select#issue_template')
          second_target.select_option
          wait_for_ajax
          expect(page).to have_selector('#issue_template_confirm_to_replace_dialog')
          expect(issue_subject.value).not_to eq "#{first_template.issue_title} #{second_template.issue_title}"
          expect(issue_description.value).not_to eq "#{first_template.description}\n\n#{second_template.description}"
        end
      end
    end
  end

  private

  def visit_new_issue(user)
    # TODO: If does not user update, authentication is failed. This is workaround.
    user.update_attribute(:admin, false)
    log_user(user.login, user.password)
    visit "/projects/#{project.identifier}/issues/new"
  end
end
