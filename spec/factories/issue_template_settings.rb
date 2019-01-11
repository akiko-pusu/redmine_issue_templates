FactoryBot.define do
  factory :issue_template_setting do |t|
    association :project
    t.sequence(:help_message) { |n| "Project-#{n}: temlpate help" }
    t.enabled { true }
    t.inherit_templates { false }
    t.should_replaced { false }
  end
end
