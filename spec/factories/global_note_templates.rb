FactoryBot.define do
  factory :global_note_template do |t|
    association :tracker
    t.sequence(:name) { |n| "global_template-title: #{n}" }
    t.sequence(:description) { |n| "global_template-description: #{n}" }
    t.sequence(:memo) { |n| "global_template-note: #{n}" }
    t.sequence(:position) { |n| n }
    t.enabled { true }
    t.author_id { 1 }
    t.visibility { 2 } # open

    factory :global_note_template_with_projects do
      transient do
        projects_count { 5 }
      end

      after(:create) do |global_note_template, evaluator|
        global_note_template.projects = create_list(:project, evaluator.projects_count)
      end
    end
  end
end
