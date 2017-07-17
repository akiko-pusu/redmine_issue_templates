require_relative '../spec_helper'

describe IssueTemplate do
  let(:tracker) { FactoryGirl.create(:tracker, :with_default_status) }
  let(:project) { FactoryGirl.create(:project) }
  let(:issue_template) { FactoryGirl.create(:issue_template, tracker_id: tracker.id, project_id: project.id) }
  let(:issue_template2) { FactoryGirl.create(:issue_template, tracker_id: tracker.id, project_id: project.id) }
  it 'Instance of IssueTemplate' do
    expect(issue_template).to be_an_instance_of(IssueTemplate)
  end

  describe 'scope .orphaned' do
    subject { IssueTemplate.orphaned.count }
    before do
      issue_template.update_attribute(:tracker_id, 0)
    end
    it { is_expected.to eq 1 }
  end

  describe '#enabled?' do
    it 'return true / false correctly' do
      expect(issue_template.enabled?).to be_truthy
      issue_template.enabled = false
      expect(issue_template.enabled?).to be_falsey
    end
  end

  describe '#sort_by_position' do
    it 'do sort by position correctly' do
      expect([issue_template, issue_template2]).to eq [issue_template2, issue_template].sort
      expect(IssueTemplate.order_by_position.first).to eq issue_template
    end

    it 'do sort by position correctly after update' do
      issue_template.update(position: issue_template2.position + 100)
      expect(IssueTemplate.order_by_position.first).to eq issue_template2
    end
  end

  describe '#destroy' do
    subject { issue_template.destroy }
    context 'Template is enabled' do
      before { issue_template.enabled = true }
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
end
