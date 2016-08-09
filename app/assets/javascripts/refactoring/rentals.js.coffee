@module 'Dchq', ->
  @module 'Rentals', ->
    @module 'Index', ->
      @init =->
        $('#create-rental-overlay').on 'hidden.bs.modal', (e) ->
          $(@).find('form')[0].reset()
          $(@).find('.error-list').empty()

        $('#rental_customer_id').on 'select2-open', (e) ->
           $('.select2-drop.select2-display-none.select2-with-searchbox.select2-drop-active').css('z-index', '10001')

        $('#create-rental-overlay form').on 'submit', (e) ->
          e.preventDefault()
          self = $(@)
          $.ajax
            type: 'POST'
            url: self.attr('action')
            data: self.serialize()
            dataType: 'json'
            success: (data) ->
              window.location.href = "/rentals/#{data.id}/edit"
            error: (xhr) ->
              $('#create-rental-overlay .error-list').html($.tmpl('templates/errors', data: $.parseJSON(xhr.responseText)))

    @module 'Form', ->
      @init =->
        Dchq.Rentals.Form.autocomplete()
        Dchq.Rentals.Form.rental_products_in_lookup()

        $('form.edit_rental select:not([class=selectpicker]), form.edit_rental .shop-client-products input[type=text]').live 'change', ->
          $('form.edit_rental').submit()

        $('#add-payment-modal').on 'hidden.bs.modal', (e) ->
          $(@).find('input[type=number').val('')

        $('#search_rental_product').live 'keypress', (e)->
          if e.keyCode == 13
            e.preventDefault()
            $.post Routes.add_rental_product_rental_path($('#search_rental_product').data('rental-id'), barcode: $(@).val())


      @autocomplete =->
        $("#search_rental_product").autocomplete
          minLength: 2
          select: (event, ui) ->
            $.post Routes.add_rental_product_rental_path($('#search_rental_product').data('rental-id'), rental_product_id: ui.item.id)
          source: (request, response) ->
            $.ajax
              url: Routes.search_rental_products_path()
              dataType: 'json'
              data: {term: request.term, rental_id: $('#search_rental_product').data('rental-id')}
              success: (data) ->
                response data
                return
            return

      @rental_products_in_lookup =->
        $('a.rental-product-lookup').live 'click', ->
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
          $.post Routes.add_rental_product_rental_path($('#search_rental_product').data('rental-id'), rental_product_id: $(@).data('id'))
          $('#product-lookup-modal').modal('hide')

      show_product = (elem) ->
        $.get ['', $(elem).closest('div').attr('id'), $(elem).attr('data-id')].join('/') + '.json?type=rental', (data) ->
          $('#product-lookup-modal #brands').hide()
          $('#product-lookup-modal #categories').hide()
          $('#product-lookup-modal #products').fill_in_selector(data).show()

    @module 'Show', ->
      @init =->
        $('a.print-receipt').live 'click', (e)->
          e.preventDefault()
          $('#print').printElement()

$ ->
  Dchq.Rentals.Index.init() if $('body#rentals-index').length
  Dchq.Rentals.Form.init() if $('body#rentals-edit').length
  Dchq.Rentals.Show.init() if $('body#rentals-show').length
