FactoryBot.define do
  factory :issue_status do
    sequence(:name)     { |n| "status-name: #{n}" }
    sequence(:position) { |n| n }
    is_closed { false }
  end
end
