# frozen_string_literal: true

require_relative '../spec_helper'

describe GlobalIssueTemplate do
  describe '#valid?' do
    let(:instance) { GlobalIssueTemplate.new(tracker_id: tracker.id, title: 'sample') }
    let(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
    subject { instance.valid? }

    it 'related_link in invalid format' do
      instance.related_link = 'non url format string'
      is_expected.to be_falsey
      expect(instance.errors.messages.key?(:related_link)).to be_truthy
    end

    it 'related_link in valid format' do
      instance.related_link = 'https://valid.example.com/links.html'
      is_expected.to be_truthy
    end
  end
end
