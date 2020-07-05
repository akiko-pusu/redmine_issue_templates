# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../rails_helper'
require_relative '../support/login_helper'

RSpec.configure do |c|
  c.include LoginHelper
end

feature 'IssueTemplate', js: true do
  #
  # TODO: Change not to use Redmine's fixture but to use Factory...
  #
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :enumerations

  given(:role) { Role.find(1) }
  after do
    page.execute_script 'window.close();'
  end

  feature 'Access Redmine top page', js: true do
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
  end

  feature 'view fook for issues_sidebar' do
    given(:issue_template) { FactoryBot.create(:issue_template) }
    given!(:enabled_module) { FactoryBot.create(:enabled_module) }
    context 'When user has no priv to use issue template' do
      background do
        assign_template_priv(role, remove_permission: :show_issue_templates)
        log_user('jsmith', 'jsmith')
        visit '/projects/ecookbook/issues'
      end

      scenario 'Link to issue template list is not displayed.' do
        expect(page).not_to have_selector('h3', text: I18n.t('issue_template'))
      end
    end

    context 'When user has priv to use issue template' do
      background do
        assign_template_priv(role, add_permission: :show_issue_templates)
        log_user('jsmith', 'jsmith')
        visit '/projects/ecookbook/issues'
      end

      scenario 'Link to issue template list is displayed.' do
        expect(page).to have_selector('h3', text: I18n.t('issue_template'))
      end
    end
  end

  feature 'create template' do
    given!(:enabled_module) { FactoryBot.create(:enabled_module) }
    given(:issue_template_title) { page.find('#issue_template_title') }
    given(:issue_template_description) { page.find('#issue_template_description') }

    context 'When user has priv to  issue template' do
      given(:create_button) { page.find('#issue_template-form > input[type="submit"]') }
      given(:error_message) { page.find('#errorExplanation') }
      background do
        assign_template_priv(role, add_permission: :edit_issue_templates)
        log_user('jsmith', 'jsmith')
        visit '/projects/ecookbook/issue_templates/new'

        issue_template_title.set('')
        issue_template_description.set('Test for issue template description')
        create_button.click
        sleep(0.2)
      end

      scenario 'create template failed' do
        expect(error_message).to have_content('Title cannot be blank')
      end
    end

    # enable buildin-fields
    context 'Setting "enable_builtin_fields" is true' do
      background do
        # enable_builtin_fields
        Setting.send 'plugin_redmine_issue_templates=', 'enable_builtin_fields' => 'true'
        assign_template_priv(role, add_permission: :edit_issue_templates)
        log_user('jsmith', 'jsmith')
        visit '/projects/ecookbook/issue_templates/new'
      end

      scenario 'form for builtin_fields are shown' do
        select 'Bug', from: 'issue_template[tracker_id]'

        wait_for_ajax
        expect(page).to have_selector('div#json_generator')
        expect(page).to have_selector('select#field_selector')

        select 'Priority', from: 'field_selector'
        expect(page).to have_select('Value', options: IssuePriority.active.pluck(:name))

        select 'Watcher', from: 'field_selector'
        expect(page).to have_select('Value', options:  ['Dave Lopper :3', 'John Smith :2'])
      end
    end
  end

  feature 'Template feature at new issue screen' do
    given!(:issue_templates) do
      FactoryBot.create_list(:issue_template, 2, project_id: 1, tracker_id: 1)
    end

    given!(:named_template) do
      FactoryBot.create(:issue_template, project_id: 1, tracker_id: 1,
                                         title: 'Sample Title for rspec', description: 'Sample description for rspec')
    end
    given!(:enabled_module) { FactoryBot.create(:enabled_module) }

    background do
      assign_template_priv(role, add_permission: :show_issue_templates)
      log_user('jsmith', 'jsmith')
      visit '/projects/ecookbook/issues/new'
    end

    scenario 'Template filter is enabled.' do
      expect(page).to have_selector('div#template_area select#issue_template')
    end

    scenario 'Template pulldown is enabled.' do
      expect(page).to have_selector('a#link_template_dialog')
    end

    context 'Click Template filter popup' do
      given(:table) { page.find('div#filtered_templates_list table') }
      given(:titlebar) { page.find('#issue_template_dialog_title') }
      background do
        page.find('#link_template_dialog').click
        sleep(0.2)
      end

      scenario 'Template filter popup has template list' do
        expect(table).to have_selector('tbody tr', count: 3)
      end

      scenario 'popup Template filter' do
        expect(titlebar).to have_content('Issue template: Bug')
      end

      context 'Template filtered' do
        given(:table) { page.find('div#filtered_templates_list table') }
        given(:input) { page.find('#template_search_filter') }
        background do
          input.set('Sample Title for rspec')
        end

        scenario 'Filtered and should have only one template' do
          expect(table).to have_selector('tbody tr', count: 1)
        end

        scenario 'Click filtered link and applied template' do
          table.find('tbody > tr > td:nth-child(5) > i').click
          sleep(0.2)
          description = page.find('#issue_description')
          expect(description.value).to match 'Sample description for rspec'
        end
      end
    end

    context 'have subproject' do
      background do
        template_setting = IssueTemplateSetting.find_or_create(1)
        template_setting.inherit_templates = true
        sub_project = Project.find(3)
        sub_project.inherit_members = true
        sub_project.enabled_modules << EnabledModule.new(name: 'issue_templates')
        sub_project.save

        FactoryBot.create(:issue_template, project_id: 3, tracker_id: 1, title: 'template for subproject')
      end

      scenario 'Select sub project then template for subproject is shown' do
        sub_project = page.find('#issue_project_id > option[value="3"]')

        expect(page).to have_selector('#issue_template > optgroup > option', count: 3)
        template_option = page.find('#issue_template > optgroup > option:nth-child(1)')
        expect(template_option.text).to eq issue_templates.first.title

        sub_project.select_option

        wait_for_ajax
        template_option = page.find('#issue_template > optgroup > option:nth-child(1)')
        expect(template_option.text).to eq 'template for subproject'
      end
    end
  end

  feature 'Prevent to append the same template' do
    given(:expected_title) { 'Sample Title for rspec' }
    given(:expected_description) { 'Sample description for rspec' }

    given!(:named_template) do
      FactoryBot.create(:issue_template, project_id: 1, tracker_id: 1,
                                         title: 'bug template',
                                         issue_title: expected_title, description: expected_description)
    end

    given!(:issue_template_setting) do
      FactoryBot.create(:issue_template_setting, project_id: 1, should_replaced: false)
    end

    given!(:enabled_module) { FactoryBot.create(:enabled_module) }
    given(:issue_description) { page.find('#issue_description') }
    given(:issue_subject) { page.find('#issue_subject') }
    given(:table) { page.find('div#filtered_templates_list table') }

    # visible template dialog
    given(:template_dialog) { page.find('#issue_template_dialog', visible: false) }

    background do
      assign_template_priv(role, add_permission: :show_issue_templates)
      log_user('jsmith', 'jsmith')
      visit '/projects/ecookbook/issues/new'
    end

    context 'Issue has the same title and description with selected template' do
      background do
        issue_subject.set(expected_title)
        issue_description.set(expected_description)
        page.find('#link_template_dialog').click
        sleep(0.2)
        table.find('tbody > tr > td:nth-child(5) > i').click
        sleep(0.2)
      end

      scenario 'Title and Description should not be modified' do
        expect(issue_description.value).to eq expected_description
        expect(issue_subject.value).to eq expected_title

        # dialog should be closed
        expect(template_dialog).not_to be_visible
      end
    end

    context 'Issue has different title and description with selected template' do
      background do
        issue_subject.set('different subject')
        issue_description.set('different description')
        page.find('#link_template_dialog').click
        sleep(0.2)
        table.find('tbody > tr > td:nth-child(5) > i').click
        sleep(0.2)
      end

      scenario 'Title and Description should be appended text' do
        expect(issue_description.value).to eq "different description\n\n#{expected_description}"
        expect(issue_subject.value).to eq "different subject #{expected_title}"

        # dialog should be closed
        expect(template_dialog).not_to be_visible
      end
    end
  end

  feature 'Enabled to revert just after template applied' do
    given(:issue_description) { page.find('#issue_description') }
    given(:issue_subject) { page.find('#issue_subject') }
    given(:expected_title) { 'Sample Title for rspec' }
    given(:expected_description) { 'Sample description for rspec' }

    given!(:named_template) do
      FactoryBot.create(:issue_template, project_id: 1, tracker_id: 1,
                                         title: 'Sample Title for rspec',
                                         issue_title: 'Sample Title for rspec', description: 'Sample description for rspec')
    end
    given!(:enabled_module) { FactoryBot.create(:enabled_module) }

    background do
      assign_template_priv(role, add_permission: :show_issue_templates)
      log_user('jsmith', 'jsmith')
      visit '/projects/ecookbook/issues/new'

      issue_subject.set('Test for revert subject')
      issue_description.set('Test for revert description')

      select expected_title, from: 'issue_template'
      sleep(0.2)
    end

    scenario 'Title and Description should be appended text' do
      expect(issue_description.value).to eq "Test for revert description\n\n#{expected_description}"
      expect(issue_subject.value).to eq "Test for revert subject #{expected_title}"
    end

    scenario 'Click Revert and reverted applied template' do
      page.find('#revert_template').click
      expect(issue_description.value).to eq 'Test for revert description'
      expect(issue_subject.value).to eq 'Test for revert subject'
    end
  end

  # builtin fields test
  feature 'Can apply value to the builtin field' do
    given(:priority_name) { IssuePriority.active.sample.name }
    given(:builtin_fields_json_value) do
      {
        "issue_priority_id": priority_name,
        "issue_estimated_hours": 5
      }
    end
    given(:expected_title) { 'Sample Title for rspec' }
    given!(:enabled_module) { FactoryBot.create(:enabled_module) }
    given!(:issue_templates) do
      FactoryBot.create(:issue_template, title: expected_title,
                                         project_id: 1, tracker_id: 1, builtin_fields_json: builtin_fields_json_value)
    end
    background do
      # enable_builtin_fields
      Setting.send 'plugin_redmine_issue_templates=', 'enable_builtin_fields' => 'true'

      assign_template_priv(role, add_permission: :show_issue_templates)
      log_user('jsmith', 'jsmith')
      visit '/projects/ecookbook/issues/new'

      select expected_title, from: 'issue_template'
      sleep(0.2)
    end

    scenario 'Builtin fields are filled' do
      expect(page).to have_select('issue[priority_id]', selected: priority_name)
      expect(page.find('#issue_estimated_hours').value).to eq '5'
    end
  end
end
