module ControllerHelper
  # AuthHeader with api key (Ref.http://www.redmine.org/projects/redmine/wiki/Rest_api)
  def auth_with_user(user)
    request.headers['X-Redmine-API-Key'] = user.api_key.to_s
  end

  def clear_token
    request.headers['X-Redmine-API-Key'] = nil
  end

  shared_context 'As admin' do
    let(:user) { FactoryGirl.create(:user, status: 1, admin: is_admin) }
    let(:is_admin) { true }
  end

  shared_context 'Project and Tracler exists' do
    let(:count) { 4 }
    let(:trackers) { FactoryGirl.create_list(:tracker, 2, :with_default_status) }
    let(:projects) { FactoryGirl.create_list(:project, count) }
  end

  shared_examples 'Right response' do |status_code|
    it { expect(response.status).to eq status_code }
  end
end
