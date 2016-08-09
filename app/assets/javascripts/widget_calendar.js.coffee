//= require jquery.min
//= require jquery.ui.all
//= require fullcalendar

$ ->
  $("#calendar").fullCalendar
    editable: true
    disableDragging: true
    disableResizing: true
    header:
      left: "prev,next today"
      center: "title"
      right: "month,agendaWeek,agendaDay"

    defaultView: gon.CALENDAR_VIEW_TYPE
    firstDay: 1
    slotMinutes: 30
    loading: (bool) ->
      if bool
        $("#loading").show()
      else
        $("#loading").hide()

    events: "/events/get_public_events?public_key=#{ gon.PUBLIC_KEY }"
    timeFormat: "h:mm t{ - h:mm t} "
    dragOpacity: "0.5"
    firstHour: 8
    eventClick: (calEvent, jsEvent, view) ->
      $.get "/events/#{calEvent.id}/check_free_sets.js?public_key=#{ gon.PUBLIC_KEY }", (data) ->
        if data.has_sets is 'yes'
          window.parent.location = "/bookings/step_1.html?event_id=#{calEvent.id}&public_key=#{ gon.PUBLIC_KEY }"
        else
          alert("no free available places")

  $('#calendar').fullCalendar('gotoDate', new Date(gon.SHOW_DATE))
