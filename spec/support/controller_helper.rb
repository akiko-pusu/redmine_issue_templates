module ControllerHelper
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
