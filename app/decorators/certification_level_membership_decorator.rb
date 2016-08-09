class CertificationLevelMembershipDecorator < Draper::Decorator
  delegate_all

  def full_name
    model.instance_eval do
      "#{certification_level.try(:certification_agency).try(:name)}
       #{certification_level.try(:name)}
       ##{membership_number}"
    end
  end

  def certification_date
    return nil unless model.certification_date
    l model.certification_date, format: :default
  end
end
