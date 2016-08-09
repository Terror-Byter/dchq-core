class CustomerExperienceLevel < ActiveRecord::Base
  has_paper_trail

  validates :name, presence: true, length: { maximum: 255 }, :uniqueness => true
end
