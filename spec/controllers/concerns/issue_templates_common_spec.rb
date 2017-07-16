# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'IssueTemplatesCommon' do
  before do
    class FakesController < ApplicationController
      include Concerns::IssueTemplatesCommon
    end
    allow_any_instance_of(FakesController).to receive(:action_name).and_return('fake_action')
    User.current = FactoryGirl.build(:user)
  end
  let(:mock_controller) { FakesController.new }

  describe '#checklist_enabled?' do
    subject { mock_controller.checklist_enabled? }
    context 'checklist plugin not registered' do
      before do
        allow(Redmine::Plugin).to receive(:registered_plugins).and_return({})
      end
      it { is_expected.to be_falsey }
    end

    context 'checklist plugin registered' do
      before do
        allow(Redmine::Plugin).to receive(:registered_plugins).and_return(redmine_checklists: 'mock data')
      end
      it { is_expected.to be_truthy }
    end
  end

  describe '#log_action' do
    subject { mock_controller.log_action }

    it do
      expect(Rails.logger).to receive(:info).with("[FakesController] fake_action called by #{User.current.name}").once
      subject
    end
  end
end
