@module 'Dchq', ->
  @module 'Settings', ->
    @init =->
      $('#tag_list').make_as_taggable('#user_tag_list') if $('#tag_list').length > 0

      $(".certification-level-cost-price, .certification-level-cost-material-price").live 'keyup', ->
        elem = $(@).closest(".row-fluid")
        price = parseFloat(elem.find(".certification-level-cost-price").val())
        price = 0 if isNaN(price)

        material_price = parseFloat(elem.find(".certification-level-cost-material-price").val())
        material_price = 0 if isNaN(material_price)
        elem.find(".grand_total").text(currency_formatted(price + material_price))

    @show_hide_payment_options = (elem) ->
      if $(elem).val() is 'PayPal'
        $('#stripe').addClass 'hide'
        $('#paypal').removeClass 'hide'
        $('#epay').addClass 'hide'
      else if $(elem).val() is 'Stripe.com'
        $('#stripe').removeClass 'hide'
        $('#paypal').addClass 'hide'
        $('#epay').addClass 'hide'
      else if $(elem).val() is 'Epay'
        $('#stripe').addClass 'hide'
        $('#paypal').addClass 'hide'
        $('#epay').removeClass 'hide'


$ ->
  Dchq.Settings.init()
