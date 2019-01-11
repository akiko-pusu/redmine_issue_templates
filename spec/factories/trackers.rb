FactoryBot.define do
  factory :tracker do
    sequence(:name)     { |n| "tracker-name: #{n}" }
    sequence(:position) { |n| n }
    default_status_id { 1 }
    trait :with_default_status do
      after(:build) do |tracker|
        status = FactoryBot.create(:issue_status)
        tracker.default_status_id = status.id
      end
    end
  end
end
