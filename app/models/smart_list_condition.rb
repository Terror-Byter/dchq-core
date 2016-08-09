class SmartListCondition < ActiveRecord::Base
  has_paper_trail
  belongs_to :smart_list

  attr_accessible :resource, :which, :how_many, :value, :when

  validates :smart_list, presence: true, on: :update
  validates :which, inclusion: { in: proc { which.map(&:last) } }
  validates :resource, inclusion: { in: proc { resource.map(&:last) } }
  validates :when, inclusion: { in: proc { self.when.map(&:last) } }, allow_blank: true

  class << self
    def how_many
      [
        [I18n.t('models.smart_list_condition.more_than'), '>='],
        [I18n.t('models.smart_list_condition.less_than'), '<=']
      ]
    end

    def which
      [
        [I18n.t('models.smart_list_condition.any'), 'any'],
        [I18n.t('models.smart_list_condition.specific_item'), 'specific']
      ]
    end

    def resource
      [
        [I18n.t('models.smart_list_condition.product_purchased'), 'product_purchased'],
        [I18n.t('models.smart_list_condition.product_not_purchased'), 'product_not_purchased'],
        [I18n.t('models.smart_list_condition.event_completed'), 'event_completed'],
        [I18n.t('models.smart_list_condition.event_not_completed'), 'event_not_completed'],
        [I18n.t('models.smart_list_condition.courses_completed'), 'course_completed'],
        [I18n.t('models.smart_list_condition.courses_not_completed'), 'course_not_completed'],
        [I18n.t('models.smart_list_condition.servicing_completed'), 'servicing_completed'],
        [I18n.t('models.smart_list_condition.rental_completed'), 'rental_completed']
      ]
    end

    def when
      [
        [I18n.t('models.smart_list_condition.last_7_days'), '7_days'],
        [I18n.t('models.smart_list_condition.last_4_weeks'), '4_weeks'],
        [I18n.t('models.smart_list_condition.last_6_months'), '6_months'],
        [I18n.t('models.smart_list_condition.last_1_year'), '1_years'],
        [I18n.t('models.smart_list_condition.last_2_years'), '2_years'],
        [I18n.t('models.smart_list_condition.ever'), nil]
      ]
    end
  end
end
