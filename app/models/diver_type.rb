class DiverType < ActiveRecord::Base
  has_paper_trail

  attr_accessible :name
  
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
end
