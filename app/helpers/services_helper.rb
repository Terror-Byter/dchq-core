module ServicesHelper
  def mark_as_complete_buttons
    return unless resource.may_to_complete?

    if current_store.email_setting.disable_service_ready_for_collection_email? || resource.customer.email.blank?
      form_tag complete_service_path(resource), { method: :post } do
        content_tag :button, class: "btn btn-primary btn-icon glyphicons ok_2", type: :submit do
          "#{content_tag :i, ' '}#{t('services.show.mark_service')}".html_safe
        end
      end
    else
      link_to '#servicing-complete', class: 'btn btn-primary btn-icon glyphicons ok_2', :'data-toggle' => 'modal' do
        "#{content_tag :i, ' '}#{t('services.show.mark_service')}".html_safe
      end
    end
  end
end
