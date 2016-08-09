@charts =

  # init charts on finances page
  initFinances: ->

    # init simple chart
    @chart_simple.init()


  # init charts on Charts page
  initCharts: ->

    # init simple chart
    @chart_simple.init()

    # init lines chart with fill & without points
    @chart_lines_fill_nopoints.init()

    # init ordered bars chart
    @chart_ordered_bars.init()

    # init donut chart
    @chart_donut.init()

    # init stacked bars chart
    @chart_stacked_bars.init()

    # init pie chart
    @chart_pie.init()

    # init horizontal bars chart
    @chart_horizontal_bars.init()

    # init live chart
    @chart_live.init()


  # init charts on dashboard
  initIndex: ->

    # chart_ordered_bars
    #@chart_ordered_bars.init()

    # init traffic sources pie
    @chart_lines_fill_nopoints.init()


  # utility class
  utility:
    chartColors: [themerPrimaryColor, "#444", "#777", "#999", "#DDD", "#EEE"]
    chartBackgroundColors: ["#fff", "#fff"]
    applyStyle: (that) ->
      that.options.colors = charts.utility.chartColors
      that.options.grid.backgroundColor = colors: charts.utility.chartBackgroundColors
      that.options.grid.borderColor = charts.utility.chartColors[0]
      that.options.grid.color = charts.utility.chartColors[0]


    # generate random number for charts
    randNum: ->
      (Math.floor(Math.random() * (1 + 40 - 20))) + 20

  traffic_sources_pie:

    # data
    data: [
      label: "organic"
      data: 60
    ,
      label: "direct"
      data: 22.1
    ,
      label: "referral"
      data: 16.9
    ,
      label: "cpc"
      data: 1
    ]

    # chart object
    plot: null

    # chart options
    options:
      series:
        pie:
          show: true
          redraw: true
          radius: 1
          tilt: 0.6
          label:
            show: true
            radius: 1
            formatter: (label, series) ->
              "<div style=\"font-size:8pt;text-align:center;padding:5px;color:#fff;\">" + Math.round(series.percent) + "%</div>"

            background:
              opacity: 0.8

      legend:
        show: true

      colors: []
      grid:
        hoverable: true

      tooltip: true
      tooltipOpts:
        content: "<strong>%y% %s</strong>"
        dateFormat: "%y-%0m-%0d"
        shifts:
          x: 10
          y: 20

        defaultTheme: false


    # initialize
    init: ->

      # apply styling
      charts.utility.applyStyle this
      @plot = $.plot($("#pie"), @data, @options)


  # traffic sources dataTables
  # we are now using Google Charts instead of Flot
  traffic_sources_dataTables:

    # tables data
    data:
      tableSources:
        data: null
        init: ->
          data = new google.visualization.DataTable()
          data.addColumn "string", "source"
          data.addColumn "string", "medium"
          data.addColumn "number", "visits"
          data.addColumn "number", "pg_views"
          data.addColumn "string", "avg_time"
          data.addRows 7
          data.setCell 0, 0, "google", null,
            style: "text-align: center;"

          data.setCell 0, 1, "organic", null,
            style: "text-align: center;"

          data.setCell 0, 2, 89, null,
            style: "text-align: center;"

          data.setCell 0, 3, 299, null,
            style: "text-align: center;"

          data.setCell 0, 4, "00:01:48", null,
            style: "text-align: center;"

          data.setCell 1, 0, "(direct)", null,
            style: "text-align: center;"

          data.setCell 1, 1, "(none)", null,
            style: "text-align: center;"

          data.setCell 1, 2, 14, null,
            style: "text-align: center;"

          data.setCell 1, 3, 34, null,
            style: "text-align: center;"

          data.setCell 1, 4, "00:03:15", null,
            style: "text-align: center;"

          data.setCell 2, 0, "yahoo", null,
            style: "text-align: center;"

          data.setCell 2, 1, "organic", null,
            style: "text-align: center;"

          data.setCell 2, 2, 3, null,
            style: "text-align: center;"

          data.setCell 2, 3, 3, null,
            style: "text-align: center;"

          data.setCell 2, 4, "00:00:00", null,
            style: "text-align: center;"

          data.setCell 3, 0, "ask", null,
            style: "text-align: center;"

          data.setCell 3, 1, "organic", null,
            style: "text-align: center;"

          data.setCell 3, 2, 1, null,
            style: "text-align: center;"

          data.setCell 3, 3, 3, null,
            style: "text-align: center;"

          data.setCell 3, 4, "00:01:34", null,
            style: "text-align: center;"

          data.setCell 4, 0, "bing", null,
            style: "text-align: center;"

          data.setCell 4, 1, "organic", null,
            style: "text-align: center;"

          data.setCell 4, 2, 1, null,
            style: "text-align: center;"

          data.setCell 4, 3, 1, null,
            style: "text-align: center;"

          data.setCell 4, 4, "00:00:00", null,
            style: "text-align: center;"

          data.setCell 5, 0, "conduit", null,
            style: "text-align: center;"

          data.setCell 5, 1, "organic", null,
            style: "text-align: center;"

          data.setCell 5, 2, 1, null,
            style: "text-align: center;"

          data.setCell 5, 3, 1, null,
            style: "text-align: center;"

          data.setCell 5, 4, "00:00:00", null,
            style: "text-align: center;"

          data.setCell 6, 0, "google", null,
            style: "text-align: center;"

          data.setCell 6, 1, "cpc", null,
            style: "text-align: center;"

          data.setCell 6, 2, 1, null,
            style: "text-align: center;"

          data.setCell 6, 3, 1, null,
            style: "text-align: center;"

          data.setCell 6, 4, "00:00:00", null,
            style: "text-align: center;"

          @data = data
          data

      tableReffering:
        data: null
        init: ->
          data = new google.visualization.DataTable()
          data.addColumn "string", "source"
          data.addColumn "number", "pg_views"
          data.addColumn "string", "avg_time"
          data.addColumn "string", "exits"
          data.addRows 6
          data.setCell 0, 0, "google.ro"
          data.setCell 0, 1, 14, null,
            style: "text-align: center;"

          data.setCell 0, 2, "00:05:51", null,
            style: "text-align: center;"

          data.setCell 0, 3, "3", null,
            style: "text-align: center;"

          data.setCell 1, 0, "search.sweetim.com"
          data.setCell 1, 1, 5, null,
            style: "text-align: center;"

          data.setCell 1, 2, "00:03:29", null,
            style: "text-align: center;"

          data.setCell 1, 3, "1", null,
            style: "text-align: center;"

          data.setCell 2, 0, "start.funmoods.com"
          data.setCell 2, 1, 5, null,
            style: "text-align: center;"

          data.setCell 2, 2, "00:01:02", null,
            style: "text-align: center;"

          data.setCell 2, 3, "1", null,
            style: "text-align: center;"

          data.setCell 3, 0, "google.md"
          data.setCell 3, 1, 2, null,
            style: "text-align: center;"

          data.setCell 3, 2, "00:03:56", null,
            style: "text-align: center;"

          data.setCell 3, 3, "1", null,
            style: "text-align: center;"

          data.setCell 4, 0, "searchmobileonline.com"
          data.setCell 4, 1, 2, null,
            style: "text-align: center;"

          data.setCell 4, 2, "00:02:21", null,
            style: "text-align: center;"

          data.setCell 4, 3, "1", null,
            style: "text-align: center;"

          data.setCell 5, 0, "google.com"
          data.setCell 5, 1, 1, null,
            style: "text-align: center;"

          data.setCell 5, 2, "00:00:00", null,
            style: "text-align: center;"

          data.setCell 5, 3, "1", null,
            style: "text-align: center;"

          @data = data
          data


    # chart
    chart:
      tableSources: null
      tableReffering: null


    # options
    options:
      tableSources:
        page: "enable"
        pageSize: 6
        allowHtml: true
        cssClassNames:
          headerRow: "tableHeaderRow"
          tableRow: "tableRow"
          selectedTableRow: "selectedTableRow"
          hoverTableRow: "hoverTableRow"

        width: "100%"
        alternatingRowStyle: false
        pagingSymbols:
          prev: "<span class=\"btn btn-inverse\">prev</btn>"
          next: "<span class=\"btn btn-inverse\">next</span>"

      tableReffering:
        page: "enable"
        pageSize: 6
        allowHtml: true
        cssClassNames:
          headerRow: "tableHeaderRow"
          tableRow: "tableRow"
          selectedTableRow: "selectedTableRow"
          hoverTableRow: "hoverTableRow"

        width: "100%"
        alternatingRowStyle: false
        pagingSymbols:
          prev: "<span class=\"btn btn-inverse\">prev</btn>"
          next: "<span class=\"btn btn-inverse\">next</span>"


    # initialize
    init: ->

      # data
      charts.traffic_sources_dataTables.data.tableSources.init()
      charts.traffic_sources_dataTables.data.tableReffering.init()

      # charts
      charts.traffic_sources_dataTables.drawTableSources()
      charts.traffic_sources_dataTables.drawTableReffering()


    # draw Traffic Sources Table
    drawTableSources: ->
      @chart.tableSources = new google.visualization.Table(document.getElementById("dataTableSources"))
      @chart.tableSources.draw @data.tableSources.data, @options.tableSources


    # draw Refferals Table
    drawTableReffering: ->
      @chart.tableReffering = new google.visualization.Table(document.getElementById("dataTableReffering"))
      @chart.tableReffering.draw @data.tableReffering.data, @options.tableReffering


  # simple chart
  chart_simple:

    # data
    data:
      sin: []
      cos: []


    # will hold the chart object
    plot: null

    # chart options
    options:
      grid:
        show: true
        aboveData: true
        color: "#3f3f3f"
        labelMargin: 5
        axisMargin: 0
        borderWidth: 0
        borderColor: null
        minBorderMargin: 5
        clickable: true
        hoverable: true
        autoHighlight: true
        mouseActiveRadius: 20
        backgroundColor: {}

      series:
        grow:
          active: false

        lines:
          show: true
          fill: false
          lineWidth: 4
          steps: false

        points:
          show: true
          radius: 5
          symbol: "circle"
          fill: true
          borderColor: "#fff"

      legend:
        position: "se"

      colors: []
      shadowSize: 1
      tooltip: true #activate tooltip
      tooltipOpts:
        content: "%s : %y.3"
        shifts:
          x: -30
          y: -50

        defaultTheme: false


    # initialize
    init: ->

      # apply styling
      charts.utility.applyStyle this
      unless @plot?
        i = 0

        while i < 14
          @data.sin.push [i, Math.sin(i)]
          @data.cos.push [i, Math.cos(i)]
          i += 0.5
      @plot = $.plot($("#chart_simple"), [
        label: "Sin"
        data: @data.sin
        lines:
          fillColor: "#DA4C4C"

        points:
          fillColor: "#fff"
      ,
        label: "Cos"
        data: @data.cos
        lines:
          fillColor: "#444"

        points:
          fillColor: "#fff"
      ], @options)


  # lines chart with fill & without points
  chart_lines_fill_nopoints:

    # chart data
    data:
      d1: []
      d2: []


    # will hold the chart object
    plot: null

    # chart options
    options:
      grid:
        show: true
        aboveData: true
        color: "#3f3f3f"
        labelMargin: 5
        axisMargin: 0
        borderWidth: 0
        borderColor: null
        minBorderMargin: 5
        clickable: true
        hoverable: true
        autoHighlight: true
        mouseActiveRadius: 20
        backgroundColor: {}

      series:
        grow:
          active: false

        lines:
          show: true
          fill: true
          lineWidth: 2
          steps: false

        points:
          show: false

      legend:
        position: "nw"

      yaxis:
        min: 0

      xaxis:
        ticks: 11
        tickDecimals: 0

      colors: []
      shadowSize: 1
      tooltip: true
      tooltipOpts:
        content: "%s : %y.0"
        shifts:
          x: -30
          y: -50

        defaultTheme: false


    # initialize
    init: ->

      # apply styling
      charts.utility.applyStyle this

      # generate some data
      @data.d1 = gon.line_chart

      # make chart
      @plot = $.plot("#chart_lines_fill_nopoints", [
        label: I18n.t('js.charts.revenue')
        data: @data.d1
        lines:
          fillColor: "#fff8f2"

        points:
          fillColor: "#88bbc8"
      ], @options)


  # ordered bars chart
  chart_ordered_bars:

    # chart data
    data: null

    # will hold the chart object
    plot: null

    # chart options
    options:
      bars:
        show: true
        barWidth: 0.2
        fill: 1

      grid:
        show: true
        aboveData: false
        color: "#3f3f3f"
        labelMargin: 5
        axisMargin: 0
        borderWidth: 0
        borderColor: null
        minBorderMargin: 5
        clickable: true
        hoverable: true
        autoHighlight: false
        mouseActiveRadius: 20
        backgroundColor: {}

      series:
        grow:
          active: false

      legend:
        position: "ne"

      colors: []
      tooltip: true
      tooltipOpts:
        content: "%s : %y.0"
        shifts:
          x: -30
          y: -50

        defaultTheme: false


    # initialize
    init: ->

      # apply styling
      charts.utility.applyStyle this

      @data = [
        label: "Product 1"
        data: [50, 100]
      ,
        label: "Product 2"
        data: [30, 90]
      ]
      #@data = gon.staff_targets
      #console.log(@data)
      @plot = $.plot($("#chart_ordered_bars"), @data, @options)


  # donut chart
  chart_donut:

    # chart data
    data: [
      label: "USA"
      data: 38
    ,
      label: "Brazil"
      data: 23
    ,
      label: "India"
      data: 15
    ,
      label: "Turkey"
      data: 9
    ,
      label: "France"
      data: 7
    ,
      label: "China"
      data: 5
    ,
      label: "Germany"
      data: 3
    ]

    # will hold the chart object
    plot: null

    # chart options
    options:
      series:
        pie:
          show: true
          innerRadius: 0.4
          highlight:
            opacity: 0.1

          radius: 1
          stroke:
            color: "#fff"
            width: 8

          startAngle: 2
          combine:
            color: "#EEE"
            threshold: 0.05

          label:
            show: true
            radius: 1
            formatter: (label, series) ->
              "<div class=\"label label-inverse\">" + label + "&nbsp;" + Math.round(series.percent) + "%</div>"

        grow:
          active: false

      legend:
        show: false

      grid:
        hoverable: true
        clickable: true
        backgroundColor: {}

      colors: []
      tooltip: true
      tooltipOpts:
        content: "%s : %y.1" + "%"
        shifts:
          x: -30
          y: -50

        defaultTheme: false


    # initialize
    init: ->

      # apply styling
      charts.utility.applyStyle this
      @plot = $.plot($("#chart_donut"), @data, @options)


  # horizontal bars chart
  chart_horizontal_bars:

    # chart data
    data: null

    # will hold the chart object
    plot: null

    # chart options
    options:
      grid:
        show: true
        aboveData: false
        color: "#3f3f3f"
        labelMargin: 5
        axisMargin: 0
        borderWidth: 0
        borderColor: null
        minBorderMargin: 5
        clickable: true
        hoverable: true
        autoHighlight: false
        mouseActiveRadius: 20
        backgroundColor: {}

      series:
        grow:
          active: false

        bars:
          show: true
          horizontal: true
          barWidth: 0.2
          fill: 1

      legend:
        position: "ne"

      colors: []
      tooltip: true
      tooltipOpts:
        content: "%s : %y.0"
        shifts:
          x: -30
          y: -50

        defaultTheme: false


    # initialize
    init: ->

      # apply styling
      charts.utility.applyStyle this
      d1 = []
      i = 0

      while i <= 5
        d1.push [parseInt(Math.random() * 30), i]
        i += 1
      d2 = []
      i = 0

      while i <= 5
        d2.push [parseInt(Math.random() * 30), i]
        i += 1
      d3 = []
      i = 0

      while i <= 5
        d3.push [parseInt(Math.random() * 30), i]
        i += 1
      @data = new Array()
      @data.push
        data: d1
        bars:
          horizontal: true
          show: true
          barWidth: 0.2
          order: 1

      @data.push
        data: d2
        bars:
          horizontal: true
          show: true
          barWidth: 0.2
          order: 2

      @data.push
        data: d3
        bars:
          horizontal: true
          show: true
          barWidth: 0.2
          order: 3

      @plot = $.plot($("#chart_horizontal_bars"), @data, @options)


  # pie chart
  chart_pie:

    # chart data
    data: [
      label: "USA"
      data: 38
    ,
      label: "Brazil"
      data: 23
    ,
      label: "India"
      data: 15
    ,
      label: "Turkey"
      data: 9
    ,
      label: "France"
      data: 7
    ,
      label: "China"
      data: 5
    ,
      label: "Germany"
      data: 3
    ]

    # will hold the chart object
    plot: null

    # chart options
    options:
      series:
        pie:
          show: true
          highlight:
            opacity: 0.1

          radius: 1
          stroke:
            color: "#fff"
            width: 2

          startAngle: 2
          combine:
            color: "#353535"
            threshold: 0.05

          label:
            show: true
            radius: 1
            formatter: (label, series) ->
              "<div class=\"label label-inverse\">" + label + "&nbsp;" + Math.round(series.percent) + "%</div>"

        grow:
          active: false

      colors: []
      legend:
        show: false

      grid:
        hoverable: true
        clickable: true
        backgroundColor: {}

      tooltip: true
      tooltipOpts:
        content: "%s : %y.1" + "%"
        shifts:
          x: -30
          y: -50

        defaultTheme: false


    # initialize
    init: ->

      # apply styling
      charts.utility.applyStyle this
      @plot = $.plot($("#chart_pie"), @data, @options)


  # stacked bars chart
  chart_stacked_bars:

    # chart data
    data: null

    # will hold the chart object
    plot: null

    # chart options
    options:
      grid:
        show: true
        aboveData: false
        color: "#3f3f3f"
        labelMargin: 5
        axisMargin: 0
        borderWidth: 0
        borderColor: null
        minBorderMargin: 5
        clickable: true
        hoverable: true
        autoHighlight: true
        mouseActiveRadius: 20
        backgroundColor: {}

      series:
        grow:
          active: false

        stack: 0
        lines:
          show: false
          fill: true
          steps: false

        bars:
          show: true
          barWidth: 0.5
          fill: 1

      xaxis:
        ticks: 11
        tickDecimals: 0

      legend:
        position: "ne"

      colors: []
      shadowSize: 1
      tooltip: true
      tooltipOpts:
        content: "%s : %y.0"
        shifts:
          x: -30
          y: -50

        defaultTheme: false


    # initialize
    init: ->

      # apply styling
      charts.utility.applyStyle this
      d1 = []
      i = 0

      while i <= 10
        d1.push [i, parseInt(Math.random() * 30)]
        i += 1
      d2 = []
      i = 0

      while i <= 10
        d2.push [i, parseInt(Math.random() * 20)]
        i += 1
      d3 = []
      i = 0

      while i <= 10
        d3.push [i, parseInt(Math.random() * 20)]
        i += 1
      @data = new Array()
      @data.push
        label: "Data One"
        data: d1

      @data.push
        label: "Data Two"
        data: d2

      @data.push
        label: "Data Tree"
        data: d3

      @plot = $.plot($("#chart_stacked_bars"), @data, @options)


  # live chart
  chart_live:

    # chart data
    data: []
    totalPoints: 300
    updateInterval: 200

    # we use an inline data source in the example, usually data would
    # be fetched from a server
    getRandomData: ->
      @data = @data.slice(1)  if @data.length > 0

      # do a random walk
      while @data.length < @totalPoints
        prev = (if @data.length > 0 then @data[@data.length - 1] else 50)
        y = prev + Math.random() * 10 - 5
        y = 0  if y < 0
        y = 100  if y > 100
        @data.push y

      # zip the generated y values with the x values
      res = []
      i = 0

      while i < @data.length
        res.push [i, @data[i]]
        ++i
      res


    # will hold the chart object
    plot: null

    # chart options
    options:
      series:
        grow:
          active: false

        shadowSize: 0
        lines:
          show: true
          fill: true
          lineWidth: 2
          steps: false

      grid:
        show: true
        aboveData: false
        color: "#3f3f3f"
        labelMargin: 5
        axisMargin: 0
        borderWidth: 0
        borderColor: null
        minBorderMargin: 5
        clickable: true
        hoverable: true
        autoHighlight: false
        mouseActiveRadius: 20
        backgroundColor: {}

      colors: []
      tooltip: true
      tooltipOpts:
        content: "Value is : %y.0"
        shifts:
          x: -30
          y: -50

        defaultTheme: false

      yaxis:
        min: 0
        max: 100

      xaxis:
        show: true


    # initialize
    init: ->

      # apply styling
      charts.utility.applyStyle this
      @plot = $.plot($("#chart_live"), [@getRandomData()], @options)
      setTimeout @update, charts.chart_live.updateInterval


    # update
    update: ->
      charts.chart_live.plot.setData [charts.chart_live.getRandomData()]
      charts.chart_live.plot.draw()
      setTimeout charts.chart_live.update, charts.chart_live.updateInterval