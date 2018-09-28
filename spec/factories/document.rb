FactoryBot.define do
  factory :document do
    sequence(:name) { |n| "file#{n}" }
  end
end
