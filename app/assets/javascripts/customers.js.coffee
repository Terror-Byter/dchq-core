@module 'Dchq', ->
  @module 'Customer', ->
    @module 'Show', ->
      @init =->
        $('#add-customer-to-event').on 'shown.bs.modal', (e) ->
          $.post "/customers/#{$(@).data('id')}/get_events.js"

        $('a[href="#tab-2"]').click (e) ->
          $.post "/customers/#{$('#add-customer-to-event').data('id')}/load_sales.js"

        $('a[href="#tab-3"]').click (e) ->
          $.post "/customers/#{$('#add-customer-to-event').data('id')}/load_ecp.js"

$ ->
  Dchq.Customer.Show.init() if $('#customers-show').length

  $('#tag_list').make_as_taggable('#customer_tag_list') if $('#tag_list').length > 0

  $('form').on 'nested:fieldAdded', (event) ->
    $('.selectpicker').selectpicker()

  cert_levs = $('.original_certification_levels').html()

  $('select.certification_level').each (index, elem) ->
    update_cert_list(elem, cert_levs)

  $('.certification_agency').live 'change', ->
    elem = $(@).closest('.row-fluid').find('select.certification_level')
    update_cert_list(elem, cert_levs)

  $('.primary').live 'change', (event) ->
    $('.primary:checked').attr('checked', false)
    $(@).attr('checked', true)

update_cert_list = (elem, cert_levs) ->
  agency  = $(elem).closest('.row-fluid').find('.certification_agency :selected').text()
  options = $(cert_levs).filter("optgroup[label='#{agency}']").html()
  $(elem).html(options)
  $(elem).selectpicker('refresh').selectpicker('val', $(elem).data('selected'))
