# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'IssueTemplatesCommon' do
  before do
    class FakesController < ApplicationController
      include Concerns::IssueTemplatesCommon
    end
    allow_any_instance_of(FakesController).to receive(:action_name).and_return('fake_action')
    User.current = FactoryBot.build(:user)
  end
  let(:mock_controller) { FakesController.new }

  describe '#log_action' do
    subject { mock_controller.log_action }

    it do
      expect(Rails.logger).to receive(:info).with("[FakesController] fake_action called by #{User.current.name}").once
      subject
    end
  end
end
