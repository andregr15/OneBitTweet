FactoryBot.define do
  factory :trending do
    hashtags {
      [ 
        "##{FFaker::Lorem.word}": Random.rand(15..20), 
        "##{FFaker::Lorem.word}": Random.rand(10..14), 
        "##{FFaker::Lorem.word}": Random.rand(5..9), 
        "##{FFaker::Lorem.word}": Random.rand(1..4)
      ]
    }
  end
end