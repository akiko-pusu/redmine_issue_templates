# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../rails_helper'
require_relative '../support/login_helper'

RSpec.configure do |c|
  c.include LoginHelper
end

feature 'Confirm dialog before overwrite description', js: true do
  background(:all) do
    Redmine::Plugin.register(:redmine_issue_templates) do
      settings partial: 'settings/redmine_issue_templates',
               default: { 'apply_global_template_to_all_projects' => 'false' }
    end
  end

  given(:user) { FactoryBot.create(:user, :password_same_login, login: 'manager', language: 'en', admin: false) }
  given(:project) { create(:project_with_enabled_modules) }
  given(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  given(:role) { FactoryBot.create(:role, :manager_role) }
  given(:issue_priority) { FactoryBot.create(:priority) }
  given(:first_target) { page.find('#issue_template > optgroup > option:nth-child(1)') }
  given(:second_target) { page.find('#issue_template > optgroup > option:nth-child(2)') }
  given(:issue_subject) { page.find('#issue_subject') }
  given(:issue_description) { page.find('#issue_description') }
  given(:first_template) { IssueTemplate.first }
  given(:second_template) { IssueTemplate.second }

  given(:related_link) { page.find('#issue_template_related_link') }

  background do
    FactoryBot.create_list(:issue_template, 2, project_id: project.id, tracker_id: tracker.id,
                                               related_link: 'http://example.com/template/wiki#usage')

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

    expect(related_link.text).to eq 'Related Link'
    expect(related_link['href']).to eq 'http://example.com/template/wiki#usage'
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

        scenario 'Conform window not apperead with using cookie.' do
          visit_new_issue(user)

          # set cookie
          page.driver.browser.manage.add_cookie(name: 'issue_template_confirm_to_replace_hide_dialog', value: '1')
          expect(page).to have_selector('div#template_area select#issue_template')
          second_target.select_option
          wait_for_ajax
          expect(page).not_to have_selector('#issue_template_confirm_to_replace_dialog')
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
