@module 'Dchq', ->
  @module 'StoreSettings', ->
    @init =->
      $('form').on 'nested:fieldAdded', (event) ->
        $("#additional_shop_location").html calculate_addional_shop_location("+")
        $("#total_monthly_price").html calculate_total_monthly_price("+")

      $('form').on 'nested:fieldRemoved', (event) ->
        $("#additional_shop_location").html calculate_addional_shop_location("-")
        $("#total_monthly_price").html calculate_total_monthly_price("-")

    calculate_addional_shop_location = (symbol) ->
      current_value = parseInt($("#additional_shop_location").html())
      next_value = (if (symbol is "-") then current_value - 1 else current_value + 1)
      next_value + " Location"

    calculate_total_monthly_price = (symbol) ->
      current_value = parseFloat($("#total_monthly_price").html().match(/\d+.\d+/) + "")
      next_value = (if symbol is "-" then current_value - gon.EXTRA_STORE_PRICE else current_value + gon.EXTRA_STORE_PRICE)
      "£" + currency_formatted(next_value) + "/month"

$ ->
  Dchq.StoreSettings.init()
