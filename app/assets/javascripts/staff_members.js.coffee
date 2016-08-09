$ ->
  $('#tag_list').make_as_taggable('#user_tag_list') if $('#tag_list').length > 0

  $('body#staff-members-schedule').on 'click', 'a.mark_as_available', (e) ->
    e.preventDefault()
    self = $(@)

    #if confirm('You are about to change this day to available. Are you sure you want to proceed?')
    $.ajax
      url: self.attr('href')
      method: 'GET'
      success: (data) ->
        self.attr('href', self.attr('href').replace('mark_as_available', 'mark_as_day_off')).removeClass('mark_as_available')
          .addClass('mark_as_day_off').text('available').css('color': '#fff').closest('td').css('background-color', 'green')

  $('body#staff-members-schedule').on 'click', 'a.mark_as_day_off', (e) ->
    e.preventDefault()
    self = $(@)

    $.ajax
      url: self.attr('href')
      method: 'GET'
      success: (data) ->
        self.attr('href', self.attr('href').replace('mark_as_day_off', 'mark_as_available')).removeClass('mark_as_day_off')
          .addClass('mark_as_available').text(data.title).css('color': '').closest('td').css('background-color', data.color)
