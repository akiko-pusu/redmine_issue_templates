# frozen_string_literal: true
require_relative '../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../support/controller_helper')

describe SettingsController do
  include_context 'As admin'
  before do
    @request.session[:user_id] = user.id
  end

  describe '#GET plugin' do
    render_views
    before do
      get :plugin, id: 'redmine_issue_templates'
    end
    include_examples 'Right response', 200
    it 'Contains right plugin setting content' do
      expect(response).to render_template(partial: '_redmine_issue_templates')
      expect(response.body).to match(/id="settings_apply_global_template_to_all_projects"/im)
      expect(assigns(:plugin)).not_to be_nil
      expect(assigns(:plugin).id).to eq :redmine_issue_templates
    end

    it 'Setting default value exists' do
      settings = assigns(:settings)
      expect(settings).not_to be_nil
      # hash value is exists
      expect(settings['apply_global_template_to_all_projects']).not_to be nil
      # default value is 'false'
      expect(settings['apply_global_template_to_all_projects']).to eq 'false'
    end
  end

  describe '#POST plugin' do
    render_views
    before do
      post :plugin, id: 'redmine_issue_templates', settings: { apply_global_template_to_all_projects: true }
    end
    include_examples 'Right response', 302
    it 'Contains right plugin setting content' do
      expect(assigns(:plugin)).not_to be_nil
      expect(assigns(:plugin).id).to eq :redmine_issue_templates
    end
    it 'Setting value is changed true' do
      settings = Setting.plugin_redmine_issue_templates
      expect(settings['apply_global_template_to_all_projects']).to be_truthy
    end
  end
end
