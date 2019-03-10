module ControllerHelper
  # AuthHeader with api key (Ref.http://www.redmine.org/projects/redmine/wiki/Rest_api)
  def auth_with_user(user)
    request.headers['X-Redmine-API-Key'] = user.api_key.to_s
  end

  def clear_token
    request.headers['X-Redmine-API-Key'] = nil
  end

  def login_request(login, password)
    post '/login', params: { username: login, password: password }
  end

  def assign_template_priv(role, add_permission: nil, remove_permission: nil)
    return if add_permission.blank? && remove_permission.blank?

    role.add_permission! add_permission if add_permission.present?
    role.remove_permission! remove_permission if remove_permission.present?
  end

  shared_context 'As admin' do
    let(:user) { FactoryBot.create(:user, status: 1, admin: is_admin) }
    let(:is_admin) { true }
  end

  shared_context 'Project and Tracler exists' do
    let(:count) { 4 }
    let(:trackers) { FactoryBot.create_list(:tracker, 2, :with_default_status) }
    let(:projects) { FactoryBot.create_list(:project, count) }
  end

  shared_examples 'Right response' do |status_code|
    it { expect(response.status).to eq status_code }
  end
end
