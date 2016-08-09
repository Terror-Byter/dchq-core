class Frequency < ActiveRecord::Base
  def self.frequencies
    {"One-off"         => { name: I18n.t("activerecord.attributes.frequency.one"),             number_of_days: 0   },
     "Daily"           => { name: I18n.t("activerecord.attributes.frequency.daily"),           number_of_days: 1   },
     "Every other day" => { name: I18n.t('activerecord.attributes.frequency.every_other_day'), number_of_days: 2   },
     "Weekly"          => { name: I18n.t("activerecord.attributes.frequency.weekly"),          number_of_days: 7   },
     "Fortnightly"     => { name: I18n.t("activerecord.attributes.frequency.fortnightly"),     number_of_days: 14  },
     "Monthly"         => { name: I18n.t("activerecord.attributes.frequency.monthly"),         number_of_days: 30  },
     "Yearly"          => { name: I18n.t("activerecord.attributes.frequency.yearly"),          number_of_days: 365 }
    }
  end
end
