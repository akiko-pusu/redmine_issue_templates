# frozen_string_literal: true

require_relative '../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../support/controller_helper')

RSpec.configure do |c|
  c.include ControllerHelper
end

RSpec.describe 'Global Note Template', type: :request do
  let(:user) { FactoryBot.create(:user, :password_same_login, login: 'test-manager', language: 'en', admin: true) }
  let(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  let(:target_template_name) { 'Global Note template name' }
  let(:target_template) { GlobalNoteTemplate.last }

  before do
    # do nothing
  end

  it 'show global note template list' do
    login_request(user.login, user.login)
    get '/global_note_templates'
    expect(response.status).to eq 200

    get '/global_note_templates/new'
    expect(response.status).to eq 200
  end

  it 'create global note template and load' do
    login_request(user.login, user.login)
    post '/global_note_templates',
         params: { global_note_template:
           { tracker_id: tracker.id, name: target_template_name,
             description: 'Global Note template description', memo: 'Test memo', enabled: 1 } }
    expect(response).to have_http_status(302)

    post '/note_templates/load', params: { note_template: { note_template_id: target_template.id, template_type: 'global' } }
    json = JSON.parse(response.body)
    expect(target_template.name).to eq(json['note_template']['name'])
  end
end
