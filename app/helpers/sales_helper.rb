module SalesHelper
  def finalize_button(sale)
    css_class = 'btn btn-success btn-large input-block-level btn-icon glyphicons ok'
    data_status = sale.refund? ? 'complete_refund' : 'complete'
    title = sale.refund? ? 'Issue Refund' : 'Finalise Sale'

    if data_status.eql?("complete_refund")
      link_to "#{content_tag(:i, nil)}#{title}".html_safe, "#refund_payment_method", class: css_class, :'data-toggle' => :modal
    else
      link_to "#{content_tag(:i, nil)}#{title}".html_safe, "javascript:void(0)", class: "#{css_class} finalize-sale", :"data-status" => data_status
    end
  end
end
