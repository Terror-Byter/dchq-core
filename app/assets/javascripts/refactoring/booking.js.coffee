@module 'Dchq', ->
  @module 'Booking', ->
    @module 'Step_1', ->
      @init =->
        $("#event_customer_participant_id, #kit_hire_select, #insurance_select, .additionals select, .transports select").change ->
          submitForm()

        validateCustomerEmail()

        $('.accordion-inner a.next-step').click (e)->
          if $(@).attr('href') == '#collapse-2-1'
            e.stopPropagation()
            $.post( Routes.check_certificate_customers_path(format: 'js'), { email: $('#customer_email').val(), public_key: $('#public_key').val() } )
          else
            $($(@).attr('href')).closest('.accordion-group').removeClass('hide')

         $(".btn.btn-primary.btn-icon.glyphicons.stripe").click (e) ->
           $form = $(@).closest('form')

           # Disable the submit button to prevent repeated clicks
           $form.find("button").prop "disabled", true
           Stripe.createToken $form, stripeResponseHandler

           # Prevent the form from submitting with the default action
           false

        cert_levs = $('.original_certification_levels').html()

        $('#certification_agency_id').live 'change', ->
          elem = $('#certification_level_id')
          updateCertList(elem, cert_levs)

      updateCertList = (elem, cert_levs) ->
        agency  = $(elem).closest('.row-fluid').find('#certification_agency_id :selected').text()
        options = $(cert_levs).filter("optgroup[label='#{agency}']").html()
        $(elem).html(options)
        $(elem).selectpicker('refresh').selectpicker('val', $(elem).data('selected'))

      stripeResponseHandler = (status, response) ->
        $form = $("form.ecp_form")
        if response.error
          # Show the errors on the form
          $(".alert.alert-error").remove()
          $form.prepend "<div class='alert alert-error' id='alert alert-error'><button class='close' data-dismiss='alert'>×</button><h4>There was an issue processing this payment:</h4><ul><li>" + response.error.message + "</li></ul></div>"
          $form.find("button").prop "disabled", false
        else
          # token contains id, last4, and card type
          token = response.id
          # Insert the token into the form so it gets submitted to the server
          $form.append $("<input type=\"hidden\" name=\"stripe_card_token\" />").val(token)
          # and re-submit
          $form.get(0).submit()
        return

      submitForm = ->
        form = $(".ecp_form")
        $.ajax
          url: '/bookings/calculate_price.json'
          data: form.serialize().replace(/&_method=[a-z]+/, '')
          type: 'POST'
          success: (data) ->
            if data.errors
              alert(errors)
            else
              $('#insurance').html(data.insurance)
              $('#kit_hire').html(data.kit_hire)
              $('#transport').html(data.transport)
              $('#additionals').html(data.additionals)
              $('#discount').html(data.discount)
              $('#event_text_price').html(data.event_text_price)
              $('#total_price').html(data.total_price)

      validateCustomerEmail = (email) ->
        re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        re.test($('#customer_email').val())

$ ->
  Dchq.Booking.Step_1.init() if $('body.bookings').length
