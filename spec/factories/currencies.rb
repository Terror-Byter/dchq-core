FactoryGirl.define do
  factory :currency do
    name "US Dollar"
    unit "$"
    code "USD"
    separator "."
    delimiter ","
    format "%u%n"
    precision 2
  end
end
