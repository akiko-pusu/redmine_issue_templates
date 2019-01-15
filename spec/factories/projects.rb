FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "project-name: #{n}" }
    sequence(:description) { |n| "project-description: #{n}" }
    sequence(:identifier) { |n| "project-#{n}" }
    homepage { 'http://ecookbook.somenet.foo/' }
    is_public { true }

    trait :with_enabled_modules do
      after(:build) do |tracker|
        status = FactoryBot.create(:issue_status)
        tracker.default_status_id = status.id
      end
    end

    factory :project_with_enabled_modules do
      after(:create) do |project, _evaluator|
        FactoryBot.create(:enabled_module, project_id: project.id)
      end
    end
  end
end
