@module 'Dchq', ->
  @module 'CourseEvent', ->
    @init =->
      $('form').on 'nested:fieldAdded', (event) ->
        Dchq.CourseEvent.update_counter()

      $('form').on 'nested:fieldRemoved', (event) ->
        Dchq.CourseEvent.update_counter()

      Dchq.CourseEvent.update_counter()

      courses = $('#course_event_certification_level_id').html()
      Dchq.CourseEvent.update_course_list(courses)

      $('#course_event_certification_agency_id').change ->
        $('#course_event_price').val('')
        Dchq.CourseEvent.update_course_list(courses)

      $('#course_event_certification_level_id').change ->
        $.get "/events/courses/course_price?id=#{$(@).val()}", (data) ->
          $('#course_event_price').val(data)

    @update_course_list = (courses) ->
      agency  = $('#course_event_certification_agency_id :selected').text()
      options = "<option></option>" + $(courses).filter("optgroup[label='#{agency}']").html()
      $('#course_event_certification_level_id').html(options).selectpicker('refresh')

    @update_counter =->
      $('span.counter:visible').each (index) ->
        $(@).text index + 1

$ ->
  Dchq.CourseEvent.init()
