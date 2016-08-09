@module 'Dchq', ->
  @module 'SettingsPrint', ->
    @init =->
      $('#store_printer_type').change ->
        row = $('#store_tsp_url').closest('.row-fluid')
        if $(@).val() is 'tsp' then row.show() else closeAndClean(row)

    closeAndClean = (row) ->
      row.hide().find('input').val('')

$ ->
  Dchq.SettingsPrint.init() if $('body#settings-print').length
