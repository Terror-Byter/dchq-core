@module 'Dchq', ->
  @module 'Services', ->
    @init =->

      $('form').on 'nested:fieldAdded', (event) ->
        Dchq.Services.init()

      if $('select[data-type="type_of_service_id"]').length > 0
        get_type_of_service()

      $('select[data-type="type_of_service_id"]').change ->
        get_type_of_service()

      $('#service_complimentary_service').change ->
        Dchq.Services.recalculate_sub_total()

      $('.remove_nested_fields').live 'click', ->
        Dchq.Services.recalculate_sub_total()

      $('.add_item_to_service_button').click ->
        $(@).closest('.modal').modal('hide')
        $.get "/services/add_item", { product_id: $('#add-product-to-service').find('select').val() }

      $('a[href="#add_item_confirmation"]').click ->
        $(@).closest('.modal').modal('hide')

      $('form.simple_form button[type="submit"]').click (e) ->
        if $(@).closest('form').hasClass('new_service')
          e.preventDefault()
          $('#service-agreement').modal('show')

      $('form.simple_form input[type="text"]').keydown (e) ->
        if $(@).closest('form').hasClass('new_service') && e.keyCode == 13
          e.preventDefault()
          $('#service-agreement').modal('show')

      $('button.submit').click ->
        $("#service_terms_and_conditions").val("1").closest("form").submit()

      $('input:checkbox.main').change ->
        $('form input:checkbox').attr('checked', $(@).is(':checked'))

      if $('#counter').length
        count = gon.SECONDS
        timer = $.timer(->
          $("#counter").html secondsToTime(++count)
        )

        timer.set
          time: 1000
          autostart: gon.CONTINUE_TIMER

        $('a.play').click (e) ->
          e.preventDefault()
          timer.play()
          $(@).addClass('hide')
          $('a.pause').removeClass('hide')
          $.post "/services/#{$("#service_id").val()}/time_intervals"

        $('a.pause').click (e) ->
          e.preventDefault()
          timer.pause()
          $(@).addClass('hide')
          $('a.play').removeClass('hide')
          $.post "/services/#{$("#service_id").val()}/time_intervals/stop"

    secondsToTime = (secs) ->
      hours = Math.floor(secs / (60 * 60))
      divisor_for_minutes = secs % (60 * 60)
      minutes = Math.floor(divisor_for_minutes / 60)
      divisor_for_seconds = divisor_for_minutes % 60
      seconds = Math.ceil(divisor_for_seconds)
      seconds = "0#{seconds}" if seconds < 10

      obj =
        h: hours
        m: minutes
        s: seconds

      "#{obj.h}:#{obj.m}:#{obj.s}"

    get_type_of_service =->
      $.get '/services/get_type_of_service', {
        service_id: $('select[data-type="type_of_service_id"]').map(-> return this.value).get().join()
      }

    @recalculate_sub_total =->
      $('#sub_total_price').html gon.currency + currency_formatted(calculate_type_of_service() + calculate_products())

    calculate_type_of_service =->
      sum = 0
      if !$('#service_complimentary_service').is(':checked')
        $('ul.products-list li.type_of_service span').each (index, elem) ->
          sum += parseFloat($(elem).text().replace(/[^0-9\.]+/g, ''))
      sum

    calculate_products =->
      sum = 0
      $('ul.products-list li.product span').each (index, elem) ->
        sum += parseFloat($(elem).text().replace(/[^0-9\.]+/g, '')) if $(elem).is(':visible')
      sum

$ ->
  Dchq.Services.init()
