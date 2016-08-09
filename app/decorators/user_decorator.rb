class UserDecorator < Draper::Decorator
  delegate_all
  decorates_association :sales, scope: :newest_first

  def customer_mailchimp
    model.mailchimp_list_id_for_customer.blank? ? h.edit_mailchimp_step_1_settings_path : h.sync_with_mailchimp_customers_path
  end

  def customer_mailchamp_link_name
    model.mailchimp_list_id_for_customer.blank? ? I18n.t('customers.index.setup_mailchimp') : I18n.t('customers.index.sync_mailchimp')
  end

  def has_mailchimp_api_key?
    model.mailchimp_api_key.blank?
  end

  def supplier_mailchimp
    model.mailchimp_list_id_for_business_contact.blank? ? h.edit_mailchimp_step_1_settings_path : h.sync_with_mailchimp_suppliers_path
  end

  def staff_mailchimp
    model.mailchimp_list_id_for_staff_member.blank? ? h.edit_mailchimp_step_1_settings_path : h.sync_with_mailchimp_staff_members_path
  end

  def staff_mailchamp_link_name
    model.mailchimp_list_id_for_staff_member.blank? ? I18n.t("staff_members.index.setup_mailchimp") : I18n.t("staff_members.index.sync_mailchimp")
  end

  def supplier_mailchamp_link_name
    model.mailchimp_list_id_for_business_contact.blank? ? I18n.t("staff_members.index.setup_mailchimp") : I18n.t("staff_members.index.sync_mailchimp")
  end

  def name
    model.full_name
  end

  def telephone
    model.telephone
  end

  def tags
    model.tag_list.map{ |tag| h.link_to(tag, "javascript:void(0);") }.join(', ')
  end

  def image
    h.image_tag model.avatar.image(:large)
  end

  def full_address
    model.address && model.address.full_address(separator: ", ")
  end

  def telephone
    model.telephone
  end

  def emergency_contact
    model.emergency_contact_details
  end

  def tags
    model.tag_list.join('  ')
  end

  def shops
    model.stores.pluck(:name).join(', ')
  end

  def available_days
    model.available_days.map.with_index{ |k,v| h.t('date.abbr_day_names')[v] if k.last == '1' }.compact.join(', ')
  end

  def contracted_hours
    model.contracted_hours
  end

  def no_sales?
    model.sales.empty?
  end

  def no_notes?
    model.notes.empty?
  end

  def sale_target
    h.formatted_currency(model.sale_target) unless model.sale_target.blank?
  end

  def avatar_url
    if model.avatar.image_file_name.blank?
      "#{Figaro.env.host}#{model.avatar.image.url(:large)}"
    else
      model.avatar.image.url(:large)
    end
  end
end
