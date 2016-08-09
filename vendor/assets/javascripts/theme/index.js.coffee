$ ->
  # initialize charts
  charts.initIndex()  unless typeof charts is "undefined"
  return  if Modernizr.touch