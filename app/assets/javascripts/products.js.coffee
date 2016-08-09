@module 'Dchq', ->
  @module 'Products', ->
    @init =->
      $(".new_product #product_markup").keyup recalculateRetailPrice
      $(".new_product #product_supply_price").keyup recalculateRetailPrice
      $(".new_product #product_tax_rate_id").change recalculateRetailPrice if gon.tax_rate_inclusion is true
      $("#product_barcode").keypress (e) ->
        #key code 13 is "enter",
        false  if e.keyCode is 13

    recalculateRetailPrice = ->
      price = applyPercantage($("#product_supply_price").floatValue(), $("#product_markup").floatValue())
      price = applyPercantage(price, $("#product_tax_rate_id").floatValue()) if gon.tax_rate_inclusion is true
      $("#product_retail_price").val price.toFixed(2) if price

    applyPercantage = (number, percentage) ->
      number + number * (percentage / 100)

$ ->
  Dchq.Products.init()

$.fn.floatValue = ->
  value = parseFloat((if $(@).is("select") then $(@).find('option:selected').text() else $(@).val()))
  (if (not isNaN(value) and value > 0) then value else 0)
