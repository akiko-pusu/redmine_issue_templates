FactoryBot.define do
  factory :issue_template do |t|
    association :project
    association :tracker
    t.sequence(:title) { |n| "template-title: #{n}" }
    t.sequence(:issue_title) { |n| "template-issue_title: #{n}" }
    t.sequence(:description) { |n| "template-description: #{n}" }
    t.sequence(:note) { |n| "template-note: #{n}" }
    t.sequence(:position) { |n| n }
    t.enabled { true }
    t.enabled_sharing { true }
    t.author_id { 1 }
  end
end
