require_relative '../spec_helper'

describe IssueTemplateSetting do
  let(:project) { FactoryBot.create(:project) }
  let(:independent_projects) { FactoryBot.create_list(:project, 2) }
  let(:subject) do
    FactoryBot.create(:issue_template_setting,
                       project_id: project.id)
  end
  let(:child_projects) { Project.where(parent_id: project.id) }

  shared_examples 'expected for apply/unapply template' do
    context 'When no project id' do
      let(:param) {}
      it 'Raise Exception if no argument' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'When invalid project id' do
      let(:param) { 0 }
      it 'Raise  NotFound Exception if not specified valid project' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'When valid project id' do
      let(:param) { project.id }
      before do
        FactoryBot.create(:issue_template_setting, project_id: project.id)
      end

      it 'instance method is called' do
        expect_any_instance_of(IssueTemplateSetting).to receive(:update_inherit_template_of_child_projects)
        subject
      end
    end
  end

  describe '.apply_template_to_child_projects' do
    let(:subject) { IssueTemplateSetting.apply_template_to_child_projects(param) }
    it_behaves_like 'expected for apply/unapply template'
  end

  describe '.unapply_template_from_child_projects' do
    let(:subject) { IssueTemplateSetting.unapply_template_from_child_projects(param) }
    it_behaves_like 'expected for apply/unapply template'
  end

  describe '#child_projects' do
    context 'no child projects' do
      it 'return zero count' do
        expect(subject.child_projects.count).to eq 0
      end
    end

    context 'has child projects' do
      before do
        FactoryBot.create_list(:project, 2, parent_id: project.id)
      end
      it 'return right number of all the child projects' do
        expect(subject.child_projects.count).to eq 2
      end

      context 'has descendent projects' do
        before do
          FactoryBot.create_list(:project, 2, parent_id: child_projects.last.id)
        end

        it 'return right number of all the descendent projects' do
          expect(subject.child_projects.count).to eq 4
        end

        it('return zero count after breaking off relationship') do
          expect(subject.child_projects.count).to eq 4
          child_projects.each do |c|
            c.set_parent!(nil)
          end
          subject.project.reload
          expect(subject.child_projects.count).to eq 0
        end
      end
    end
  end

  describe '#apply_template_to_child_projects' do
    let(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
    let!(:enabled_module) { FactoryBot.create(:enabled_module, project_id: project.id) }
    let!(:issue_templates) do
      FactoryBot.create_list(:issue_template, 4, project_id: project.id, tracker_id: tracker.id, enabled_sharing: true)
    end
    let(:child_project_template_settings) do
      IssueTemplateSetting.where(project_id: child_projects.ids)
    end

    before do
      FactoryBot.create_list(:project, 4, parent_id: project.id)
      # change to enabled issue template module
      child_projects.each do |c|
        FactoryBot.create(:enabled_module, project_id: c.id)
        IssueTemplateSetting.find_or_create(c.id)
        c.trackers = [tracker]
        c.save
      end
      subject.apply_template_to_child_projects
    end

    it "child project inhetits parent's template" do
      expect(child_project_template_settings.first.inherit_templates).to be_truthy
    end

    it 'child project can use inherit template' do
      expect(child_project_template_settings.first.get_inherit_templates.count).to eq 4
    end

    it 'All the child projects setting should be true' do
      expect(child_project_template_settings.pluck(:inherit_templates).include?(false)).to be_falsey
    end

    it 'All the child projects setting should be false after unapplied' do
      subject.unapply_template_from_child_projects
      values_inherit_templates = child_project_template_settings.pluck(:inherit_templates)
      expect(values_inherit_templates.include?(false)).to be_truthy
      expect(values_inherit_templates.uniq.count).to eq 1
    end
  end
end
