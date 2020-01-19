# frozen_string_literal: true

require_relative '../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../support/controller_helper')

describe GlobalIssueTemplatesController, type: :controller do
  let(:count) { 4 }
  let(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  let(:projects) { FactoryBot.create_list(:project, count) }

  before do
    # Prevent to call User.deliver_security_notification when user is created.
    expect_any_instance_of(User).to receive(:deliver_security_notification).and_return(true)
    @request.session[:user_id] = user.id
  end

  include_context 'As admin'

  describe 'GET #index' do
    render_views
    before do
      get :index
    end

    context 'As Non Admin' do
      let(:is_admin) { false }
      include_examples 'Right response', 403
    end

    context 'As Admin' do
      include_examples 'Right response', 200
    end
  end

  describe 'GET #new' do
    render_views
    before do
      FactoryBot.create_list(:project, count)
      FactoryBot.create(:tracker, :with_default_status)
      get :new
    end
    include_examples 'Right response', 200
  end

  describe 'POST #create' do
    render_views
    let(:create_params) do
      { global_issue_template: { title: 'Global Template newtitle for creation test',
                                 note: 'Global note for creation test',
                                 description: 'Global Template description for creation test',
                                 tracker_id: tracker.id, enabled: 1, author_id: user.id, project_ids: project_ids } }
    end
    let(:global_issue_template) { GlobalIssueTemplate.first }

    before do
      post :create, params: create_params
    end

    context 'POST without project ids' do
      let(:project_ids) { [] }
      include_examples 'Right response', 302
      it do
        expect(global_issue_template.projects.count).to eq 0
      end
    end

    context 'POST with check all project ids' do
      let(:project_ids) { projects.map(&:id) }
      include_examples 'Right response', 302
      it do
        expect(global_issue_template.projects.count).to eq projects.count
      end
    end

    context 'POST with invalid url' do
      let(:project_ids) { [] }
      let(:create_params) do
        { global_issue_template:
          { title: 'Global Template newtitle for creation test',
            note: 'Global note for creation test',
            description: 'Global Template description for creation test',
            tracker_id: tracker.id,
            enabled: 1,
            author_id: user.id,
            project_ids: project_ids }.merge(related_link: 'bad format url') }
      end

      include_examples 'Right response', 200
      it do
        expect(global_issue_template.present?).to be_falsy
      end

      context 'POST with valid url' do
        let(:project_ids) { [] }
        let(:create_params) do
          { global_issue_template:
            { title: 'Global Template newtitle for creation test',
              note: 'Global note for creation test',
              description: 'Global Template description for creation test',
              tracker_id: tracker.id,
              enabled: 1,
              author_id: user.id,
              project_ids: project_ids }.merge(related_link: 'http://example.com/sample/index.html') }
        end

        include_examples 'Right response', 302
        it do
          expect(global_issue_template.present?).to be_truthy
        end
      end
    end
  end

  # PATCH GlobalIssueTemplatesController#edit
  describe 'PUT #update' do
    render_views
    let(:global_issue_template) do
      create(:global_issue_template_with_projects, tracker_id: tracker.id, projects_count: 3)
    end
    let(:edit_params) { { description: 'Update Test Global template', project_ids: [''] } }

    it 'Before update template has the default value' do
      expect(global_issue_template.projects.count).to eq 3
      expect(global_issue_template.description).not_to eq edit_params[:description]
    end

    it 'After update number of projects should changed' do
      put :update, params: { id: global_issue_template.id, global_issue_template: edit_params }
      expect(global_issue_template.projects.count).to eq 0
    end

    context 'PUT with builtin_fields param' do
      let(:update_params) do
        edit_params.merge(builtin_fields: builtin_fields)
      end

      before do
        Setting.send 'plugin_redmine_issue_templates=', 'enable_builtin_fields' => 'true'
        put :update, params: { id: global_issue_template.id, global_issue_template: update_params }
      end

      context 'invalid format' do
        let(:builtin_fields) { '12345' }

        include_examples 'Right response', 200

        it do
          msg = flash[:error]
          expect(msg.present?).to be_truthy
          expect(msg).to eq 'Please enter a valid JSON fotmat string.'
        end
      end

      context 'PUT with valid builtin_fields param' do
        let(:builtin_fields) { '{ "foo": "bar" }' }
        include_examples 'Right response', 302

        it do
          expect(flash[:error].present?).to be_falsy
          expect(global_issue_template.reload.builtin_fields_json).to eq JSON.parse(builtin_fields)
        end
      end
    end
  end
end
