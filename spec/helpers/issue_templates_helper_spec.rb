require_relative '../spec_helper'

describe IssueTemplatesHelper do
  describe '#project_tracker?' do
    let(:trackers) { FactoryBot.create_list(:tracker, 2, :with_default_status) }
    let(:project) { FactoryBot.create(:project) }
    let(:tracker) { trackers.first }
    subject { helper.project_tracker?(tracker, project) }

    context 'Tracker is associated' do
      before do
        project.trackers << tracker
      end
      it { is_expected.to be_truthy }
    end
    context 'Tracker is not associated' do
      before do
        project.trackers << trackers.last
      end
      it { is_expected.to be_falsey }
    end
  end

  describe '#non_project_tracker_msg' do
    it { expect(helper.non_project_tracker_msg(true)).to eq '' }
    it { expect(helper.non_project_tracker_msg(false)).to match('<font class="non_project_tracker">') }
  end

  describe '#template_target_trackers' do
    let(:trackers) { FactoryBot.create_list(:tracker, 2, :with_default_status) }
    let(:project) { FactoryBot.create(:project) }
    let(:tracker) { trackers.last }
    let(:template) do
      FactoryBot.create(:issue_template, tracker_id: tracker.id, project_id: project.id)
    end
    subject { helper.template_target_trackers(project, template) }
    before do
      project.trackers << trackers.first
    end
    it { expect(subject.include?([tracker.name, tracker.id])).to be_truthy }
    it { expect(subject.length).to eq 2 }
  end

  describe '#options_for_template_pulldown' do
    let(:options) do
      option = Struct.new(:id, :name)
      [].tap do |options|
        (0..2).each do |id|
          options << option.new(id, "name-#{id}")
        end
      end
    end
    subject { helper.options_for_template_pulldown(options) }
    it { expect(subject).to match('<option id="0" name="name-0">name-0</option>') }
  end
end
