FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    bio { "Hello, I'm a test user!" }
  end

  factory :murmur do
    content { "This is a test murmur" }
    association :user
  end

  factory :follow do
    association :follower, factory: :user
    association :followed, factory: :user
  end

  factory :like do
    association :user
    association :murmur
  end
end
