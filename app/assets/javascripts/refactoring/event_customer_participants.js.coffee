@module 'Dchq', ->
  @module 'EventCustomerParticipant', ->
    @init = ->
      $("#event_customer_participant_id_, #kit_hire_select, #insurance_select, .additionals select, .transports select, #event_customer_participant_quantity").change ->
        submit_form()

      $('#event_customer_participant_event_customer_participant_kit_hire_attributes_free, #event_customer_participant_event_customer_participant_insurance_attributes_free').change ->
        submit_form()

      $('a#switch_to_group').click (e) ->
        e.preventDefault()
        $(@).closest('.row-fluid').hide()
        $('a#switch_to_personal').closest('.row-fluid').show()

      $('a#switch_to_personal').click (e) ->
        e.preventDefault()
        $(@).closest('.row-fluid').hide()
        $('a#switch_to_group').closest('.row-fluid').show()


    submit_form = ->
      form = $(".ecp_form")
      $.post '/event_customer_participants/calculate_price', form.serialize().replace(/&_method=[a-z]+/, '')

$ ->
  Dchq.EventCustomerParticipant.init() if $('body.event-customer-participants').length
