FactoryGirl.define do
  factory :project do
    sequence(:name) { |n| "project-name: #{n}" }
    sequence(:description) { |n| "project-description: #{n}" }
    sequence(:identifier) { |n| "project-#{n}" }
    homepage 'http://ecookbook.somenet.foo/'
    is_public true
  end
end
