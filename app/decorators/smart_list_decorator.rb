class SmartListDecorator < Draper::Decorator
  delegate_all

  def conditions
    c_array = []
    model.smart_list_conditions.each do |condition|
      c_array << if condition.which == 'any'
                   any(condition)
                 else
                   specific_item(condition)
                 end
    end
    delimiter = model.join_operator == '&' ? "<b> #{ h.t('decorators.smart_list.and_c') } </b><br>" : "<b> #{ h.t('decorators.smart_list.or_c') } </b><br>"
    c_array.join(delimiter).html_safe
  end

  private
  def any condition
    "#{ h.t("decorators.smart_list.#{condition.resource}") } #{ condition.how_many } #{ condition.value } #{ time(condition) }"
  end

  def specific_item condition
    case condition.resource
    when 'product_purchased', 'product_not_purchased' then
      "#{ h.t("decorators.smart_list.#{condition.resource}") } is #{ h.current_store.products.with_deleted.find_by_id(condition.value).try(:label) } #{ time(condition) }"
    when 'event_completed', 'event_not_completed' then
      "#{ h.t("decorators.smart_list.#{condition.resource}") } is #{ h.current_store.events.find_by_id(condition.value).try(:label) } #{ time(condition) }"
    when 'course_completed', 'course_not_completed' then
      "#{ h.t("decorators.smart_list.#{condition.resource}") } is #{ courses(condition.value) } #{ time(condition) }"
    when 'servicing_completed' then
      "#{ h.t("decorators.smart_list.#{condition.resource}") } is #{ h.current_store.type_of_services.find_by_id(condition.value).try(:label) } #{ time(condition) }"
    when 'rental_completed' then
      "#{ h.t("decorators.smart_list.#{condition.resource}") } is #{ h.current_store.rental_products.with_deleted.find_by_id(condition.value).try(:label) } #{ time(condition) }"
    end
  end

  def time condition
    if condition.when.blank?
      h.t('decorators.smart_list.c_ever')
    else
      h.t("decorators.smart_list.c_#{ condition.when }")
    end
  end

  def courses value
    CertificationLevel.where( store_id: [nil, 0, h.current_store.id]).find_by_id(value).try(:name)
  end
end
