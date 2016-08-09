@module 'Dchq', ->
  @module 'FlashMessages', ->
    @init =->

    # TODO: add functionality to process messages' arrays

    flash = (type, message)->
      $('#content > .hidden-print').append(
        '<div class="alert fade in alert-'+ type +
        '"><button class="close" data-dismiss="alert">×</button>' + message +
        '</div>'
        )

    @error = (message)->
      flash('error', message)

    @info = (message)->
      flash('info', message)

    @success = (message)->
      flash('success', message)

    @warning = (message)->
      flash('warning', message)

    processMessages = (messages, type)->
      for msgData in messages
        for field, msg of msgData
          flash(type, msg)

    @processErrors = (messages)->
      processMessages(messages, 'error')

$ ->
  Dchq.FlashMessages.init()