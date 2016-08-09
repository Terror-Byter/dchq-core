//= require jquery.ba-dotimeout

@module 'Dchq', ->
  @module 'PurchaseOrder', ->
    self = @

    # main init functions

    @init = ->
#   all direct event bindings go here
      init_assign_supplier()
      init_purchase_order_items_selects()


    @init_once = ->
#    all delegated event bindings go here
      init_search_product()
      init_add_product()
      init_product_not_in_inventory()
      init_remove_supplier()
      init_purchase_order_items()
      init_purchase_order_items_supply_price()
      init_purchase_order_items_amend()
      init_notes() # because modal is at that part of the page that is not updated by AJAX code
      init_order_send_to_supplier() # because modal is at that part of the page that is not updated by AJAX code
      init_order_printing()
      init_delivery_date()
      init_order_received()
      init_order_marked_received_finally()

    # helper functions

    get_main_form = ->
      form = $('form.purchase_orders')
      if form.length == 0
        form = $('form.purchase_orders_amend')
      form

    # TODO: change default format from 'json' to 'js' throughout the file
    purchase_order_path = (action, format = 'json', query = '') ->
      form = get_main_form()
      path = "/purchase_orders/#{form.dom_id()}/#{action}.#{format}"
      if query
        path += '?' + query
      path

    products_list_path = ->
      purchase_order_path('products_list')

    add_note_path = ->
      purchase_order_path('add_note', 'js')

    submit_form = ->
      form = get_main_form()
      form.submit()

    is_supplier_assigned = ->
      self.supplier isnt undefined && self.supplier isnt null

    products_search_source = (request, response)->
      $.ajax
        url: products_list_path(),
        dataType: "json",
        data:
          term: request.term,
          supplier_id: self.supplier.id
        ,
        success: (data)->
          response(data)

    # page areas init

    init_assign_supplier = ->
      if gon.supplier_id isnt undefined
        self.supplier =
          id: gon.supplier_id

      if $('#search_supplier').length
        $('#search_supplier').autocomplete
          minLength: 2
          select: (event, ui) ->
            ($.post purchase_order_path('assign_supplier', 'js'),
              supplier_id: ui.item.id
            )
            .done ->
                self.supplier = ui.item
            .fail -> # TODO: process possible errors array differently
              Dchq.FlashMessages.error(I18n.t('purchase_orders.form.errors.error_assigning_supplier'))
            $('#assign-supplier-modal').modal('hide')
          source: purchase_order_path('suppliers_list')
        $('#assign-supplier-modal .btn.btn-primary').click ->
          $('#assign-supplier-modal').modal('hide')

    init_remove_supplier = ->
      $(document).delegate '#remove-supplier-link', 'ajax:complete', (event, jqXHR, status)->
        switch status
          when 'error'
            Dchq.FlashMessages.error(I18n.t('purchase_orders.form.errors.error_removing_supplier'))
          else
            $('#supplier-info').html('')
            $('#assign-supplier-link').show()
            $('#purchase_order_email').val('')
            $('#search_supplier').val('')
            self.supplier = null

    init_search_product = ->
      if $('#search_product').length # checking because products_list_path() is called anyways, including 'wrong' cases
        $('#search_product').autocomplete
          minLength: 2
          select: (event, ui) ->
            self.productToAdd = ui.item
            $('#quantity').val(1)
          source: products_search_source
          search: (event, ui)->
            if !is_supplier_assigned()
              event.preventDefault()
              $('#search_product').val('')
              alert I18n.t('purchase_orders.form.errors.assign_supplier_first')

        $('#search_product').focus()

    init_add_product = ->
      $('#add-product-link').click (e)->
        e.preventDefault()
        form = $('#new_purchase_order_item')
        product = self.productToAdd
        if !is_supplier_assigned()
          alert I18n.t('purchase_orders.form.errors.assign_supplier_first')
        if !$('#purchase_order_item_quantity')[0].validity.valid
          Dchq.Validation.highlightFirstError form
        else if !product
          alert I18n.t('purchase_orders.form.errors.select_product_first')
        else
          ($.post purchase_order_path('add_product', 'js'),
            product_id: product.id
            quantity: $('#purchase_order_item_quantity').val()
          )
          .done ->
              self.productToAdd = null # clear selected value
          .fail (jqXHR, textStatus, errorThrown)->
              Dchq.FlashMessages.processErrors JSON.parse jqXHR.responseText

    init_purchase_order_items_selects = ->
      $('.shop-client-products table tbody').first().find('.selectpicker').selectpicker('render')

    init_purchase_order_items = ->
      # TODO: get rid of mass assignment of form, perform selective updates
      $(document).delegate 'form.purchase_orders input[id*="quantity"]', 'keyup paste', ->
        $(@).doTimeout 'supply-price', 1000, => # capturing parent 'this'
          # setting hidden '_destroy' field's value to 'true' if count == 0 and 'false' otherwise
          $(@).siblings('input[type="hidden"][id$="_destroy"]').val(parseInt($(@).val()) == 0)
          submit_form()

    init_purchase_order_items_supply_price = ->
      $(document).delegate '.supply-price', 'keyup paste', ->
        $(@).doTimeout 'supply-price', 1000, =>
          submit_form()

    init_purchase_order_items_amend = ->
      # TODO: combine these two handlers in single parameterized function
      $(document).delegate 'form.purchase_orders_amend input[id$="quantity"]', 'keyup paste', ->
        $(@).doTimeout 'quantity', 1000, => # capturing parent 'this'
          maxVal = $(@).closest('tr').find('span[id$="quantity_max"]').text()
          curVal = $(@).val()
          if isNaN(parseInt(curVal))
            return
          else
            if maxVal - curVal < 0
              $(@).val(maxVal)
              curVal = maxVal
            $('#' + @id + '_rejected').val(maxVal - curVal)
            submit_form()
      $(document).delegate 'form.purchase_orders_amend input[id$="quantity_rejected"]', 'keyup paste', ->
        $(@).doTimeout 'quantity-rejected', 1000, => # capturing parent 'this'
          maxVal = $(@).closest('tr').find('span[id$="quantity_max"]').text()
          curVal = $(@).val()
          if isNaN(parseInt(curVal))
            return
          else
            if maxVal - curVal < 0
              $(@).val(maxVal)
              curVal = maxVal
            $('#' + @id.substr(0, @id.length - '_rejected'.length)).val(maxVal - curVal)
            submit_form()

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

    init_product_not_in_inventory = ->
      $('#product-not-in-inventory-modal').on 'show', ->
        if is_supplier_assigned()
          $('#product_supplier_id').select_option_by_value self.supplier.id
      $('#product-not-in-inventory-modal .btn.btn-primary').click (e)->
        e.preventDefault()
        form = $('#new_product')
        if Dchq.Validation.formValid form
          $('#product-not-in-inventory-modal').modal('hide')
          ($.post form.attr('action'), form.serialize(), null, 'json')
          .done ->
            Dchq.FlashMessages.success(I18n.t('purchase_orders.form.product_creation_success'))
          .fail ->
            Dchq.FlashMessages.error(I18n.t('purchase_orders.form.errors.error_creating_product'))
        else
          Dchq.Validation.highlightFirstError form
      # the barcode will be the same as SKU for this form
      $('#product_sku_code').bind 'keyup paste', ->
        val = $(@).val()
        $('#product_barcode').val(val)

    init_order_send_to_supplier = ->
      validate_supplier_email = (input)->
        if /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i.test($(input).val())
          $('#email-supplier-modal .modal-body').removeClass('control-group').removeClass('error')
          input.emailValid = true
        else
          $('#email-supplier-modal .modal-body').addClass('control-group').addClass('error')
          input.emailValid = false

      $('#email-supplier-modal').on 'show', (e)->
        if !is_supplier_assigned()
          e.preventDefault()
          alert I18n.t('purchase_orders.form.errors.assign_supplier_first')
        if $('.shop-client-products table').get(0).rows.length == 1
          e.preventDefault()
          alert I18n.t('purchase_orders.form.errors.add_items_to_order')

      $('#purchase_order_email').bind 'keyup paste', ->
        validate_supplier_email(this)

      $('#email-supplier-modal .btn.btn-primary').click (e)->
        e.preventDefault()
        validate_supplier_email($('#purchase_order_email').get(0))
        if $('#purchase_order_email').get(0).emailValid
          $('#email-supplier-modal form').submit()

      $('#pdf-supplier-mark-sent-modal .btn.btn-success').click (e)->
        e.preventDefault()
        $('#pdf-supplier-mark-sent-modal').modal('hide')
        $.post purchase_order_path('set_status'),
          status: 'sent_to_supplier'
        .done ->
          ($.get purchase_order_path('update_order_form_after_send','js')).done ->
            window.location.href = $('#pdf-supplier-mark-sent-modal .btn.btn-success').prop('href') # to get the pdf
        .fail ->
          Dchq.FlashMessages.error(I18n.t('purchase_orders.form.errors.failed_to_mark_order_sent'))

      $('#pdf-supplier-mark-sent-modal .btn.btn-primary').click ->
        $('#pdf-supplier-mark-sent-modal').modal('hide')
        # not setting status because order must be already 'pending'

    init_order_printing = ->
      $(document).delegate 'a.print', 'click', (e)->
        e.preventDefault()
        $('#print').printElement()

    init_delivery_date = ->
      $(document).delegate '#add-expected-delivery-date .btn.btn-primary', 'click', (e)->
        e.preventDefault()
        $('#add-expected-delivery-date').modal('hide')
        form = $('.expected-delivery-form')
        ($.post purchase_order_path('set_expected_delivery', 'js'), form.serialize())
        .fail ->
          Dchq.FlashMessages.error(I18n.t('purchase_orders.form.errors.error_setting_delivery_date'))
      $(document).delegate 'a[href="#add-expected-delivery-date"]', 'click', ->
        $('#purchase_order_expected_delivery').val($('#expected-delivery-hidden').text())

    init_order_received = ->
      $(document).delegate '#set-status-received-in-part-link', 'click', (e)->
        e.preventDefault()
        $('#set-status-received-in-part-form').submit()
      $(document).delegate '#set-status-received-in-full-link', 'click', (e)->
        e.preventDefault()
        $('#set-status-received-in-full-form').submit()

    selectedForm = null

    init_order_marked_received_finally = ->
      selectedForm = $('#mark-received-and-send-form')
      $('#purchase_order_mark_received').change (e)->
        if $(@).is(':checked')
          selectedForm = $('#mark-received-and-send-form')
        else
          selectedForm = $('#mark-received-form')
      $('#update-packing-list-modal .btn.btn-primary').click (e)->
        e.preventDefault()
        selectedForm.submit()

$ ->
  Dchq.PurchaseOrder.init()
  Dchq.PurchaseOrder.init_once()