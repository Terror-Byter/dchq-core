$ ->
  $("#other_event_frequency").change ->
    if $(@).val() is "One-off"
      $("#other_event_number_of_frequencies").val(0)
    else
      $('#number-of-frequency').modal('show')

  $("#number_of_frequencies").live "change", ->
    $("#other_event_number_of_frequencies").val($(@).val())

  show_hide_trips_select()
  $('#other_event_event_type_id').change ->
    show_hide_trips_select()

  $('#other_event_event_trip_id').change ->
    $.get "/events/standard/trip_price", { id: $(@).val() }, (data) ->
      $('#other_event_price').val(data.cost)

  $("#number_of_recurring_events_for_update").change ->
    $("#other_event_number_of_recurring_events_for_update").val $(@).val()

show_hide_trips_select = ->
  if $('#other_event_event_type_id :selected').text() is 'Trip'
    $('#other_event_event_trip_id').closest('.span3').fadeIn 500
  else
    $("#other_event_price").val('')
    $('#other_event_event_trip_id').selectpicker('val', '').closest('.span3').fadeOut 500

