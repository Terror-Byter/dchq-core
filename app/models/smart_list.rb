class SmartList < ActiveRecord::Base
  has_paper_trail

  belongs_to :company

  has_many :smart_list_conditions, dependent: :destroy, order: "id ASC"

  attr_accessible :name, :company, :company_id, :smart_list_conditions_attributes, :join_operator

  accepts_nested_attributes_for :smart_list_conditions, allow_destroy: true

  validates :company, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :join_operator, inclusion: { in: proc { join_operator.map(&:last) } }

  class << self
    def join_operator
      [
        [I18n.t('models.smart_list.all'), '&'],
        [I18n.t('models.smart_list.any'), '|']
      ]
    end
  end
end
