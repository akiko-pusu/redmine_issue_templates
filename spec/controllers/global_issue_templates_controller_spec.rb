# frozen_string_literal: true
require_relative '../spec_helper'

describe GlobalIssueTemplatesController do
  let(:user) { FactoryGirl.create(:user, status: 1, admin: is_admin) }
  let(:is_admin) { true }
  let(:count) { 4 }
  let(:tracker) { FactoryGirl.create(:tracker, :with_default_status) }

  shared_examples 'Right response' do |status_code|
    it { expect(response.status).to eq status_code }
  end

  before do
    @request.session[:user_id] = user.id
  end

  describe 'GET #index' do
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
    let(:params) do
      { global_issue_template: { title: 'Global Template newtitle for creation test',
                                 note: 'Global note for creation test',
                                 description: 'Global Template description for creation test',
                                 tracker_id: tracker.id, enabled: 1, author_id: user.id, project_ids: project_ids } }
    end

    before do
      post :new, params
    end

    context 'POST without project ids' do
      let(:project_ids) { [] }
      include_examples 'Right response', 302
      it do
        expect(GlobalIssueTemplate.count).to eq 1
      end
    end
  end

  # PATCH GlobalIssueTemplatesController#edit
  describe 'PATH #edit' do
  end
end
