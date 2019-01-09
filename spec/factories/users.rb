# frozen_string_literal: true

FactoryBot.define do
  factory :user do |u|
    # sequence -> exp. :login -> user1, user2.....
    u.sequence(:login)     { |n| "user#{n}" }
    u.sequence(:firstname) { |n| "User#{n}" }
    u.sequence(:lastname)  { |n| "Test#{n}" }
    u.sequence(:mail)      { |n| "user#{n}@badge.example.com" }
    u.language             { 'en' }
    # password = foo
    u.hashed_password      { '8f659c8d7c072f189374edacfa90d6abbc26d8ed' }
    u.salt                 { '7599f9963ec07b5a3b55b354407120c0' }

    # login and password is the same. (Note: login length should be longer than 7.)
    trait :password_same_login do
      after(:create) do |user|
        user.password = user.login
        user.auth_source_id = nil
        user.save
      end
    end

    trait :as_group do
      type { 'Group' }
      lastname { "Group#{n}" }
    end
  end
end
