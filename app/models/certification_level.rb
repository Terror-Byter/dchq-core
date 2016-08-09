class CertificationLevel < ActiveRecord::Base
  include CurrentStoreInfo
  include PgSearch

  belongs_to :certification_agency
  belongs_to :store

  pg_search_scope :search, against: [:full_name],
                           using: {
                             tsearch: {prefix: true, any_word: true },
                             trigram: { } },
                           ignoring: :accents
  has_paper_trail

  has_one :company, through: :store

  has_many :events
  has_many :certification_level_costs

  accepts_nested_attributes_for :certification_level_costs, allow_destroy: true, reject_if: ->(level_cost){ level_cost[:cost].blank? }

  attr_accessible :certification_agency_id, :store_id, :name, :certification_level_costs_attributes, :full_name

  validates :certification_agency, existence: { allow_blank: true }
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: [:store_id, :certification_agency_id] }
  validates :store, existence: { allow_blank: true }

  scope :for_agency_id, ->(id){ where(certification_agency_id: id) }
  scope :for_company_or_nil, ->(dc_id){ joins(:company.outer).where{ (companies.id == dc_id) | (store_id == nil) } }
  scope :added_by_admin, ->{ where{(store_id.eq 0) | (store_id.eq nil)} }
  scope :with_cost, ->(store){ includes(:certification_level_costs).where{ (certification_level_costs.id.not_eq nil) & (certification_level_costs.store_id.eq store)  } }

  #TODO: rewrite scopes to Rails 3 way
  scope :order_by_certification_agency_and_name, order: "`certification_levels`.`certification_agency_id` ASC, `certification_levels`.`name` ASC"

  before_destroy :check_owner
  before_destroy :should_has_no_events
  after_save :update_full_name

  def cost
    certification_level_costs.find_by_store_id(current_store_info.id).total_price_without_tax_rate
  end

  def tax_rate
    self.certification_level_costs.first.tax_rate
  end

  def commission_rate
    self.certification_level_costs.first.commission_rate
  end

  def commission_rate_money
    self.certification_level_costs.first.commission_rate_money
  end

  def global?
    ( store_id == 0 || store_id == nil ) && !new_record?
  end

  private
  def check_owner
    return true if caller.join("!").include?("active_admin")
    return false if self.global?
  end

  def should_has_no_events
    errors.add :base, I18n.t('models.certification_level.should_has_no_events') unless events.empty?
    errors.blank?
  end

  def update_full_name
    update_column :full_name, "#{ certification_agency.name } - #{ name }"
  end
end
