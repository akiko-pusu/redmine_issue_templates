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

  describe '#builtin_fields_json' do
    let(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
    let(:global_issue_template) do
      create(:global_issue_template, tracker_id: tracker.id)
    end
    subject { global_issue_template.update(builtin_fields_json: object) }

    context 'Data is a valid hash' do
      let(:object) { { 'key': 'value', 'foo': 'bar' } }
      it { is_expected.to be_truthy }
    end

    context 'Data is not a valid hash' do
      let(:object) { [1, 2, 3] }
      it { expect { subject }.to raise_error(ActiveRecord::SerializationTypeMismatch) }
    end
  end
end
