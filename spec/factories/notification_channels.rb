FactoryBot.define do
  factory :notification_channel do
    enabled { true }

    trait :log_file do
      kind { :log_file }
      settings { { 'path' => 'log/alerts.log', 'format' => 'plain' } }
    end

    trait :email do
      kind { :email }
      settings { { 'to' => 'test@example.com' } }
    end
  end
end
