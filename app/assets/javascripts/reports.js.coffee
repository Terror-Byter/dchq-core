@module 'Dchq', ->
  @module 'Reports', ->
    @init =->
      $('a.print').click (e) ->
        e.preventDefault()
        $('.innerLR').printElement()

$ ->
  Dchq.Reports.init()
