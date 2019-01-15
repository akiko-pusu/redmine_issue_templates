# frozen_string_literal: true

require_relative '../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../support/controller_helper')

describe SettingsController, type: :controller do
  include_context 'As admin'
  before do
    Redmine::Plugin.register(:redmine_issue_templates) do
      settings partial: 'settings/redmine_issue_templates',
               default: { 'apply_global_template_to_all_projects' => 'false' }
    end
    @request.session[:user_id] = user.id
  end

  after(:all) do
    Redmine::Plugin.unregister(:redmine_issue_templates)
  end

  describe '#GET plugin' do
    render_views
    before do
      Setting.send 'plugin_redmine_issue_templates=', 'apply_global_template_to_all_projects' => 'false'
      get :plugin, params: { id: 'redmine_issue_templates' }
    end
    include_examples 'Right response', 200
    it 'Contains right plugin setting content' do
      expect(response.body).to match(/id="settings_apply_global_template_to_all_projects"/im)
    end
  end

  describe '#POST plugin' do
    render_views
    before do
      post :plugin, params: { id: 'redmine_issue_templates',
                              settings: { apply_global_template_to_all_projects: true } }
    end
    include_examples 'Right response', 302
    it 'Setting value is changed true' do
      settings = Setting.plugin_redmine_issue_templates
      expect(settings['apply_global_template_to_all_projects']).to be_truthy
    end
  end
end
