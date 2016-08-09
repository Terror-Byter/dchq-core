@module 'Dchq', ->
  @module 'Registration', ->
    @init =->
      $('#get-support').on 'hidden.bs.modal', (e) ->
        $('#get-support form')[0].reset()

      $('#get-support form').validate
        rules:
          name:
            required: true
            minlength: 5
          email:
            required: true
            email: true
          store_name:
            required: true
            minlength: 1
          message:
            required: true
            minlength: 1

$ ->
  Dchq.Registration.init() if $('body.registrations').length
