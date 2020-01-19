# frozen_string_literal: true

require_relative '../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../support/controller_helper')

RSpec.configure do |c|
  c.include ControllerHelper
end

#
# Shared Example
#
shared_examples 'Right response for GET #index', type: :controller do
  include_examples 'Right response', 200
end

describe IssueTemplatesController do
  let(:count) { 4 }
  let(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  let(:project) { FactoryBot.create(:project) }

  include_context 'As admin'
  before do
    # Prevent to call User.deliver_security_notification when user is created.
    allow_any_instance_of(User).to receive(:deliver_security_notification).and_return(true)

    Redmine::Plugin.register(:redmine_issue_templates) do
      settings partial: 'settings/redmine_issue_templates',
               default: { 'apply_global_template_to_all_projects' => 'false' }
    end

    Setting.rest_api_enabled = '1'
    @request.session[:user_id] = user.id
    FactoryBot.create(:enabled_module, project_id: project.id)
    global_issue_templates = FactoryBot.create_list(:global_issue_template, count, tracker_id: tracker.id)
    global_issue_templates.each { |template| template.projects << project }
    FactoryBot.create(:issue_template, tracker_id: tracker.id, project_id: project.id)
    project.trackers << tracker
  end

  after(:all) do
    Redmine::Plugin.unregister(:redmine_issue_templates)
  end

  describe 'GET #index' do
    render_views

    before do
      get :index, params: { project_id: project.id }
    end
    include_examples 'Right response for GET #index'
  end

  describe 'GET #index with format.json' do
    render_views
    context 'Without auth header' do
      before do
        clear_token
        get :index, params: { project_id: project.id }, format: :json
      end
      include_examples 'Right response', 401
      after do
        clear_token
      end
    end

    context 'With auth header' do
      before do
        auth_with_user user
        get :index, params: { project_id: project.id }, format: :json
      end
      include_examples 'Right response for GET #index'
      it { expect(response.header['Content-Type']).to match('application/json') }
      it { expect(JSON.parse(response.body)).to have_key('global_issue_templates') }
      after do
        clear_token
      end
    end
  end

  describe 'GET #list_templates' do
    context 'Plugin Setting apply_global_template_to_all_projects is not activated' do
      before do
        get :list_templates, params: { project_id: project.id, issue_tracker_id: tracker.id }
      end

      include_examples 'Right response', 200
    end

    context 'Plugin Setting apply_global_template_to_all_projects is activated' do
      before do
        Setting.send 'plugin_redmine_issue_templates=', 'apply_global_template_to_all_projects' => 'true'
        get :list_templates, params: { project_id: project.id, issue_tracker_id: tracker.id }
      end

      include_examples 'Right response', 200
    end
  end

  describe 'GET #list_templates with format.json' do
    render_views
    context 'Without auth header' do
      before do
        clear_token
        get :list_templates, params: { project_id: project.id,
                                       issue_tracker_id: tracker.id }, format: :json
      end
      include_examples 'Right response', 401
      after do
        clear_token
      end
    end

    context 'With auth header' do
      before do
        auth_with_user user
        get :list_templates, params: { project_id: project.id,
                                       issue_tracker_id: tracker.id }, format: :json
      end
      include_examples 'Right response', 200
      it { expect(response.header['Content-Type']).to match('application/json') }
      it { expect(JSON.parse(response.body)).to have_key('global_issue_templates') }
      after do
        clear_token
      end
    end
  end

  # Spec for copy feature.
  describe 'GET #new with existing template id' do
    let(:original_template) { IssueTemplate.first }
    before do
      auth_with_user user
      get :new, params: { project_id: project.id, copy_from: original_template.id }
    end

    include_examples 'Right response', 200
    #
    # TODO: This example should be request spec.
    # it 'Render new form filled with copied template values' do
    #  issue_template = assigns(:issue_template)
    #  expect(issue_template.id).to be_nil
    #  expect(issue_template.title).to eq "copy_of_#{original_template.title}"
    # end
  end

  describe 'POST #create' do
    render_views
    let(:template_params) do
      { title: 'Issue Template newtitle for creation test',
        note: 'Note for creation test',
        description: 'Issue Template description for creation test',
        tracker_id: tracker.id, enabled: 1, author_id: user.id }
    end

    let(:create_params) do
      { issue_template: template_params }
    end

    let(:issue_template) { IssueTemplate.last }

    context 'POST with valid param' do
      before do
        post :create, params: create_params.merge(project_id: project.id)
      end

      include_examples 'Right response', 302
      it do
        expect(issue_template.project.id).to eq project.id
      end
    end

    context 'POST with valid builtin_fields param when enable_builtin_fields = true' do
      let(:builtin_fields) { '{ "foo": "bar" }' }
      let(:create_params) do
        { issue_template: template_params.merge(builtin_fields: builtin_fields) }
      end

      before do
        Setting.send 'plugin_redmine_issue_templates=', 'enable_builtin_fields' => 'true'
        post :create, params: create_params.merge(project_id: project.id)
      end
      include_examples 'Right response', 302
      it do
        expect(issue_template.builtin_fields_json).to eq JSON.parse(builtin_fields)
      end
    end

    context 'POST with invalid builtin_fields param when enable_builtin_fields = falsewhen enable_builtin_fields = false' do
      let(:builtin_fields) { '12345' }
      let(:create_params) do
        { issue_template: template_params.merge(builtin_fields: builtin_fields) }
      end

      before do
        Setting.send 'plugin_redmine_issue_templates=', 'enable_builtin_fields' => 'false'
        post :create, params: create_params.merge(project_id: project.id)
      end
      include_examples 'Right response', 302

      it do
        msg = flash[:error]
        expect(msg.present?).to be_falsy
      end
    end
  end

  describe 'PUT #update' do
    render_views
    let(:template_params) do
      { title: 'Issue Template updated title for update test',
        description: 'Issue Template description for update test',
        tracker_id: tracker.id, enabled: 1, author_id: user.id }
    end

    let(:issue_template) { IssueTemplate.last }

    before do
      Setting.send 'plugin_redmine_issue_templates=', 'enable_builtin_fields' => 'true'
      put :update, params: update_params.merge(id: issue_template.id, project_id: project.id)
    end

    context 'PUT with invalid builtin_fields param' do
      let(:builtin_fields) { '12345' }
      let(:update_params) do
        { issue_template: template_params.merge(builtin_fields: builtin_fields) }
      end

      include_examples 'Right response', 200

      it do
        msg = flash[:error]
        expect(msg.present?).to be_truthy
        expect(msg).to eq 'Please enter a valid JSON fotmat string.'
      end
    end

    context 'PUT with valid builtin_fields param' do
      let(:builtin_fields) { '{ "foo": "bar" }' }
      let(:update_params) do
        { issue_template: template_params.merge(builtin_fields: builtin_fields) }
      end

      include_examples 'Right response', 302

      it do
        expect(flash[:error].present?).to be_falsy
        expect(issue_template.reload.title).to eq 'Issue Template updated title for update test'
      end
    end
  end
end
