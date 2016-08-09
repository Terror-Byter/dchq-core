@module 'Dchq', ->
  @module 'Events', ->
    @init =->
      $("#calendar").fullCalendar
        monthNames: I18n.t('js.full_calendar.monthNames')
        buttonText:
          month: I18n.t('js.full_calendar.buttonText.month')
          week:  I18n.t('js.full_calendar.buttonText.week')
          day:   I18n.t('js.full_calendar.buttonText.day')
          today: I18n.t('js.full_calendar.buttonText.today')
        monthNamesShort: I18n.t('js.full_calendar.monthNamesShort')
        dayNames: I18n.t('js.full_calendar.dayNames')
        dayNamesShort: I18n.t('js.full_calendar.dayNamesShort')

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

        events: '/events/get_events'
        timeFormat: "h:mm t{ - h:mm t} "
        dragOpacity: "0.5"
        firstHour: 8
        eventClick: (calEvent, jsEvent, view) ->
          if calEvent.url
            window.location.href = calEvent.url
          else
            modal = $('#staff-availability-modal')
            modal.find('h3').html("Staff Availability for #{new Date(calEvent.start).toString('dddd, dS MMM')}")
            list = $('<ul/>');
            i = 0
            while i < calEvent.users.length
              list.append $("<li><a href='#{calEvent.users[i]['url']}'>#{calEvent.users[i]['name']}</a></li>")
              i++

            modal.find('.modal-body').html(list)
            modal.modal()

      $("#calendar").fullCalendar('gotoDate', new Date(gon.SHOW_DATE))

      if $(".unassigned").length > 0
        elem = $(".filter-bar form .uniformjs")
        elem.find("input[type='checkbox']").change ->
          if elem.closest('form').attr('action') is ''
            events =
              type: 'GET'
              url: '/events/get_events'
              data:
                unassigned: elem.find('#boats_all:checked').val()
                boat_ids: elem.find("input.checkbox:checked").map(->
                            this.value
                          ).get().join ","

            $('#calendar').fullCalendar 'removeEventSource'
            $('#calendar').fullCalendar('removeEvents')
            $('#calendar').fullCalendar 'addEventSource', events
          else
            $.ajax
              type: 'GET'
              url: '/events/list'
              data:
                unassigned: elem.find('#boats_all:checked').val()
                boat_ids: elem.find("input.checkbox:checked").map(->
                            this.value
                          ).get().join ","

      $('#toggle_staff').on 'click', ->
        toggler = $('#staff_toggler')
        toggler_value = toggler.val() == 'false' ? true : false
        toggler.val(toggler_value)

        events =
          type: 'GET'
          url: '/events/get_events'
          data:
            staff: toggler_value
            unassigned: elem.find('#boats_all:checked').val()
            boat_ids: elem.find("input.checkbox:checked").map(->
                        this.value
                      ).get().join ","

        $('#calendar').fullCalendar 'removeEventSource'
        $('#calendar').fullCalendar('removeEvents')
        $('#calendar').fullCalendar 'addEventSource', events
        false

$ ->
  Dchq.Events.init() if $("body#events-index").length
