# frozen_string_literal: true

require_relative '../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../support/controller_helper')

RSpec.configure do |c|
  c.include ControllerHelper
end

RSpec.describe 'Note Template', type: :request do
  let(:user) { FactoryBot.create(:user, :password_same_login, login: 'test-manager', language: 'en', admin: false) }
  let(:project) { FactoryBot.create(:project_with_enabled_modules) }
  let(:tracker) { FactoryBot.create(:tracker, :with_default_status) }
  let(:role) { FactoryBot.create(:role, :manager_role) }
  let(:target_template) { NoteTemplate.last }

  before do
    project.trackers << tracker
    assign_template_priv(role, add_permission: :show_issue_templates)
    assign_template_priv(role, add_permission: :edit_issue_templates)
    member = Member.new(project: project, user_id: user.id)
    member.member_roles << MemberRole.new(role: role)
    member.save
  end

  it 'show note template list' do
    login_request(user.login, user.login)
    get "/projects/#{project.identifier}/note_templates"
    expect(response.status).to eq 200

    get "/projects/#{project.identifier}/note_templates/new"
    expect(response.status).to eq 200
  end

  it 'create note template and load' do
    login_request(user.login, user.login)
    post "/projects/#{project.identifier}/note_templates",
         params: { note_template:
           { tracker_id: tracker.id, name: 'Note template name',
             description: 'Note template description', memo: 'Test memo', enabled: 1 } }
    expect(response).to have_http_status(302)

    post '/note_templates/load', params: { note_template: { note_template_id: target_template.id } }
    json = JSON.parse(response.body)
    expect(target_template.name).to eq(json['note_template']['name'])
  end
end
