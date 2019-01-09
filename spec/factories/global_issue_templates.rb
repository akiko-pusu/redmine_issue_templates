FactoryBot.define do
  factory :global_issue_template do |t|
    association :tracker
    t.sequence(:title) { |n| "global_template-title: #{n}" }
    t.sequence(:description) { |n| "global_template-description: #{n}" }
    t.sequence(:note) { |n| "global_template-note: #{n}" }
    t.sequence(:position) { |n| n }
    t.enabled { true }
    t.is_default { false }
    t.author_id { 1 }

    factory :global_issue_template_with_projects do
      transient do
        projects_count { 5 }
      end

      after(:create) do |global_issue_template, evaluator|
        global_issue_template.projects = create_list(:project, evaluator.projects_count)
      end
    end
  end
end
