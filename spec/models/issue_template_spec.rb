# frozen_string_literal: true

require_relative '../spec_helper'

describe IssueTemplate do
  let(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  let(:project) { FactoryBot.create(:project) }
  let(:issue_template) { FactoryBot.create(:issue_template, tracker_id: tracker.id, project_id: project.id) }
  let(:issue_template2) { FactoryBot.create(:issue_template, tracker_id: tracker.id, project_id: project.id) }
  it 'Instance of IssueTemplate' do
    expect(issue_template).to be_an_instance_of(IssueTemplate)
  end

  describe 'scope .orphaned' do
    subject { IssueTemplate.orphaned.count }
    before do
      # Remove related tracker
      issue_template.tracker.delete
    end
    it { is_expected.to eq 1 }
  end

  describe 'scope: .sorted' do
    it 'do sort by position correctly' do
      expect([issue_template, issue_template2]).to eq [issue_template2, issue_template].sort
      expect(IssueTemplate.sorted.first).to eq issue_template
    end

    it 'do sort by position correctly after update' do
      issue_template.update(position: issue_template2.position + 100)
      expect(IssueTemplate.sorted.first).to eq issue_template2
    end
  end

  describe '#destroy' do
    subject { issue_template.destroy }
    context 'Template is enabled' do
      before do
        issue_template.enabled = true
        issue_template.save
      end
      it 'Failed to remove with invalid message' do
        expect(Rails.logger).to receive(:info).with(/\[Destroy\] IssueTemplate: /).never
        subject
        expect(issue_template.errors.present?).to be_truthy
      end
    end
    context 'Template is disabled' do
      before { issue_template.enabled = false }
      it 'Removed and log message is generated' do
        expect(Rails.logger).to receive(:info).with(/\[Destroy\] IssueTemplate: /).once
        subject
        expect(issue_template.errors.present?).to be_falsey
      end
    end
  end

  describe '#valid?' do
    let(:instance) { described_class.new(tracker_id: tracker.id, project_id: project.id, title: 'sample') }
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
    subject { issue_template.update(builtin_fields_json: object) }

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
