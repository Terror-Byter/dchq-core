$ ->
  individual = $('#xero-individual')

  if $('#store_xero_attributes_integration_type').val() == 'individual'
    individual.show()
  else
    individual.hide()

  $('#store_xero_attributes_integration_type').on 'change', ->
    if $(this).val() == 'individual'
      individual.show()
    else
      individual.hide()
