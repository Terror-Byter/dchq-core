@module 'Dchq', ->
  @module 'Sale', ->
    @init =->
      init_autocomplete()

      $('.selectpicker').selectpicker()
      $('#search_product').focus()

    @init_once =->
      init_notes() # because modal is at that part of the page that is not updated by AJAX code
      init_submit_buttons()
      init_products_in_lookup()
      init_search()
      handle_icon_plus()
      $('.quantity select').live 'change', ->
        submit_form()

      $('#misc-product-modal').find("button[type='submit']").live 'click', ->
        $('#misc-product-modal').modal('hide')

      $('#add-payment-modal select').live 'change', ->
        if $(@).find('option:selected').text() is 'Gift Card'
          $('#add-payment-modal input[type="number"]').attr('placeholder', 'Gift Card ID')
        else
          $('#add-payment-modal input[type="number"]').attr('placeholder', '0.00')

      $('#sales form').live 'submit', ->
        $('#add-payment-modal').modal('hide')

      $('a.print-receipt').live 'click', (e)->
        e.preventDefault()
        $('#print').printElement()

      $('#product-lookup-modal').live 'hidden', ->
        $('#product-lookup-modal #products').hide()

      $('.refund-checkbox input[type=checkbox]').live 'change', ->
        $('tr.refund-total, .refund-total-dropdown').removeClass('hide') if $('.refund-checkbox input:checked').length > 0
        $('tr.refund-total, .refund-total-dropdown').addClass('hide') if $('.refund-checkbox input:checked').length == 0

    add_note_path = ->
      form = $('form.sales')
      "/sales/#{form.dom_id()}/add_note.js"

    sale_path = (action, format = 'json', query = '') ->
      form = get_main_form()
      path = "/sales/#{form.dom_id()}/#{action}.#{format}"
      if query
        path += '?' + query
      path

    init_notes = ->
      $('#add-note-modal .btn.btn-primary').click (e)->
        e.preventDefault()
        $('#add-note-modal').modal('hide')

        note = $('#add-note-modal textarea').val()
        $.post add_note_path(),
          note: note
        .fail ->
          Dchq.FlashMessages.error(I18n.t('purchase_orders.form.errors.error_adding_note'))

      $(document).delegate '#edit-note', 'click', (e)->
        e.preventDefault()
        $('#add-note-modal textarea').val($('#note-holder').text())
        $('#add-note-modal').modal('show')

    init_search =->
      $('#search_product').live 'keypress', (e)->
        if e.keyCode == 13
          e.preventDefault()
          $.get sales_member_path('search_product'), { barcode: $(@).val() }

    sales_member_path = (action) ->
      "/sales/#{$('form.sales').dom_id()}/#{action}.js"

    init_autocomplete = (sale_id) ->
      $("#search_product").autocomplete
        minLength: 2
        select: (event, ui) ->
          $.post sales_member_path("add_product"),
            product_id: ui.item.id
            class_type: if ui.item.class_type == 'Product' then 'StoreProduct' else ui.item.class_type

        source: sales_member_path("products_list")

      $("#search_customer").autocomplete
        minLength: 2
        select: (event, ui) ->
          $.post sales_member_path("add_customer"),
            customer_id: ui.item.id
          $('#assign-customer-modal').modal('hide')

        source: sales_member_path("customers_list")

    submit_form =->
      $('#sales form:first').submit()

    init_submit_buttons =->
      $('a.save_as_layby, .cart_total a.btn-success.finalize-sale').live 'click', ->
        $.get sales_member_path('mark_as_complete'), { 'status': $(@).attr('data-status') }

    show_product = (elem) ->
      $.get ['', $(elem).closest('div').attr('id'), $(elem).attr('data-id')].join('/') + '.json', (data) ->
        $('#product-lookup-modal #brands').hide()
        $('#product-lookup-modal #categories').hide()
        $('#product-lookup-modal #products').fill_in_selector(data).show()

    init_products_in_lookup = ->
      $('a.product-lookup').live 'click', ->
        $('#product_lookup #products').hide()

        $.get '/brands.json', (data) ->
          $('#product-lookup-modal #brands').fill_in_selector(data)
        $.get '/categories.json', (data) ->
          $('#product-lookup-modal #categories').fill_in_selector(data)

      $('#product-lookup-modal #brands a').live 'click', ->
        show_product(@)
      $('#product-lookup-modal #categories a').live 'click', ->
        show_product(@)

      $('#product-lookup-modal #products a').live 'click', ->
        $.post(sales_member_path('add_product'), {'product_id' : $(@).attr('data-id'), 'class_type' : 'Product' })
        $('#product-lookup-modal').modal('hide')

    handle_icon_plus = ->
      $('td.discount').find("input").live 'focusout',  ->
        submit_form()
      $('td.discount').find("select").live 'change', ->
        submit_form()

$ ->
  Dchq.Sale.init()
  Dchq.Sale.init_once()
