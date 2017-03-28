# frozen_string_literal: true
require_relative '../spec_helper'

describe GlobalIssueTemplatesController do
  let(:user) { FactoryGirl.create(:user, status: 1, admin: is_admin) }
  let(:projects) do
    FactoryGirl.create_list(:project)
  end
  let(:tracker) do
    FactoryGirl.create(:tracker, :with_default_status)
  end

  shared_examples 'Right response' do
    it { expect(response.status).to eq status_code }
  end

  describe 'GET #index' do
    before do
      @request.session[:user_id] = user.id
      get :index
    end

    context 'As Non Admin' do
      let(:status_code) { 403 }
      let(:is_admin) { false }
      include_examples 'Right response'
    end

    context 'As Admin' do
      let(:status_code) { 200 }
      let(:is_admin) { true }
      include_examples 'Right response'
    end
  end
end
