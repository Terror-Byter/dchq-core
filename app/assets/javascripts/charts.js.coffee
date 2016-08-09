//= require_tree ../../../vendor/assets/javascripts/flot/.

$ ->
  $('#chart_ordered_bars').jqBarGraph
    data: gon.staff_targets
    type: 'multi'
    colors: ['#55ab48', '#777777']
    legends: [I18n.t('js.charts.target'), I18n.t('js.charts.actual')]
    prefix: gon.currency_unit
    legend: true
    width: false
    height: false
