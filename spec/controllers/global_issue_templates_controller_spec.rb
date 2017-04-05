# frozen_string_literal: true
require_relative '../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../support/controller_helper')

describe GlobalIssueTemplatesController do
  let(:count) { 4 }
  let(:tracker) { FactoryGirl.create(:tracker, :with_default_status) }
  let(:projects) { FactoryGirl.create_list(:project, count) }

  before do
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
      FactoryGirl.create_list(:project, count)
      FactoryGirl.create(:tracker, :with_default_status)
      get :new
    end
    include_examples 'Right response', 200
    it do
      template = assigns(:global_issue_template)
      expect(template).not_to be_nil
      expect(template.title.blank?).to be_truthy
      expect(template.description.blank?).to be_truthy
    end
  end

  describe 'POST #create' do
    render_views
    let(:params) do
      { global_issue_template: { title: 'Global Template newtitle for creation test',
                                 note: 'Global note for creation test',
                                 description: 'Global Template description for creation test',
                                 tracker_id: tracker.id, enabled: 1, author_id: user.id, project_ids: project_ids } }
    end
    let(:global_issue_template) { GlobalIssueTemplate.first }

    before do
      post :new, params
    end

    context 'POST without project ids' do
      let(:project_ids) { [] }
      include_examples 'Right response', 302
      it do
        expect(assigns(:global_issue_template)).to eq global_issue_template
        expect(global_issue_template.projects.count).to eq 0
      end
    end

    context 'POST with check all project ids' do
      let(:project_ids) { projects.map(&:id) }
      include_examples 'Right response', 302
      it do
        expect(assigns(:global_issue_template)).to eq global_issue_template
        expect(global_issue_template.projects.count).to eq projects.count
      end
    end
  end

  # PATCH GlobalIssueTemplatesController#edit
  describe 'PUT #edit' do
    render_views
    let(:global_issue_template) do
      create(:global_issue_template_with_projects, tracker_id: tracker.id, projects_count: 3)
    end
    let(:params) { { description: 'Update Test Global template', project_ids: [] } }

    it 'Before update template has the default value' do
      expect(global_issue_template.projects.count).to eq 3
      expect(global_issue_template.description).not_to eq params[:description]
    end

    it 'After update number of projects should changed' do
      put :edit, id: global_issue_template.id, global_issue_template: params
      template = assigns(:global_issue_template)
      expect(template.description).to eq params[:description]
      expect(global_issue_template.projects.count).to eq 0
    end
  end
end
