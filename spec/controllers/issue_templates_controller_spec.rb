# frozen_string_literal: true
require_relative '../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../support/controller_helper')

describe IssueTemplatesController do
  let(:count) { 4 }
  let(:tracker) { FactoryGirl.create(:tracker, :with_default_status) }
  let(:project) { FactoryGirl.create(:project) }

  include_context 'As admin'
  before do
    Redmine::Plugin.register(:redmine_issue_templates) do
      settings partial: 'settings/redmine_issue_templates',
               default: { 'apply_global_template_to_all_projects' => 'false' }
    end

    @request.session[:user_id] = user.id
    FactoryGirl.create(:enabled_module, project_id: project.id)
    global_issue_templates = FactoryGirl.create_list(:global_issue_template, count, tracker_id: tracker.id)
    global_issue_templates.each { |template| template.projects << project }
    FactoryGirl.create(:issue_template, tracker_id: tracker.id, project_id: project.id)
    project.trackers << tracker
  end

  describe 'GET #index' do
    render_views

    before do
      get :index, project_id: project.id
    end

    include_examples 'Right response', 200
    it 'Return both global template and project local template' do
      global_templates = assigns(:global_issue_templates)
      template_map = assigns(:template_map)
      expect(global_templates).not_to be_nil
      expect(global_templates.count).to eq count
      expect(template_map).not_to be_nil
    end

    it 'Project local template exists' do
      template_map = assigns(:template_map)
      expect(template_map[tracker].count).to eq 1
    end
  end

  describe 'GET #list_templates' do
    context 'Plugin Setting apply_global_template_to_all_projects is not activated' do
      before do
        get :list_templates, project_id: project.id, issue_tracker_id: tracker.id
      end

      include_examples 'Right response', 200
      it 'Return Global templates and project local templates' do
        global_templates = assigns(:global_templates)
        expect(global_templates).not_to be_nil
        expect(global_templates.count).to eq 4
      end
    end

    context 'Plugin Setting apply_global_template_to_all_projects is activated' do
      before do
        Setting.send 'plugin_redmine_issue_templates=', 'apply_global_template_to_all_projects' => 'true'
        get :list_templates, project_id: project.id, issue_tracker_id: tracker.id
      end

      include_examples 'Right response', 200
      it 'Return project local templates only' do
        global_templates = assigns(:global_templates)
        expect(global_templates).not_to be_nil
        expect(global_templates.count).to eq 0
      end
    end
  end
end
