Searchad.Views.QueryMonitoring ||= {}
Searchad.Views.QueryMonitoring.Metric ||= {}
Searchad.Views.QueryMonitoring.Metric.Stats ||= {}

class Searchad.Views.QueryMonitoring.Metric.Stats.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('qm-metric:sub-content-cleanup', @unrender)
    @data = {}
    @active = false


  seriesTypes: [
    {
    name: "ATC Lower Bound"
    color:"#c0c0c0"
    type:"areaspline"
    },
    {
    name: "ATC"
    color:"blue"
    type:"spline"
    }
  ]

  # seriesTypes: [
  #   {column: "atc_LCL"
  #   name: "ATC Lower Bound"
  #   color:"#c0c0c0"
  #   type:"areaspline"
  #   },
  #   {
  #   column: "atc_metric"
  #   name: "ATC"
  #   color:"blue"
  #   type:"spline"
  #   },
  #   {column: "atc_UCL"
  #   name: "ATC Upper Bound"
  #   color:"#c0c0c0"
  #   type:"areaspline"
  #   }
  # ]

  initChart: (title, series) =>
    title = "ACT metric monitoring for " + title
    that = this
    console.log('title', title, 'series', series)
    @$el.highcharts('StockChart',
      chart:
        alignTicks: false
      # rangeSelector:
      #   selected: 0
      credits:
        enabled: false
      xAxis:
        type: 'datetime'
        labels:
          formatter: ->
            Highcharts.dateFormat('%b %e', @value)
      yAxis: [{
        title:
          text: 'atc metric'
        gridLineWidth: 0}]
          # {title:
          #   text: 'ATC value'
          # opposite: true
          # type: 'linear'
          # gridLineWidth: 0}]

      title:
        text: title
        useHTML: true
        align: "center"
        floating: true
      plotOptions:
        series:
          marker:
            # enabled: false
            states:
              hover:
                enabled: true
        # areaspline:
        #   events:
        #     click: (e) ->
        #       that.goto_query_analysis(e.point.x) if e.point.x?
        spline:
          events:
            click: (e) ->
              that.goto_query_analysis(e.point.x) if e.point.x?

        # scatter: 
        #   marker: 
        #     radius: 5
        #     states: 
        #       hover:
        #         enabled: true,
        #         lineColor: 'rgb(100,100,100)'
        

      legend:
        enabled: true
        layout: 'horizontal'
        align: 'center'
        verticalAlign: 'bottom'
        borderWidth: 0
      series: series)

  unrender: =>
    @active = false
    @$el.highcharts().destroy() if @$el.highcharts()
    @controller.trigger('qm-count:sub-content:hide-spin')

  
  get_items: (data) =>
    @active = true
    @$el.highcharts().destroy() if @$el.highcharts()
    @controller.trigger('qm-count:sub-content:show-spin')
    @$el.find('.ajax-loader').show()
    $.ajax(
      url: '/monitoring/metric/get_query_stats.json'
      data:
        query: data.query
      success: (ajax_data, status) =>
        console.log("success")
        console.log("ajax_data", ajax_data)
        if ajax_data and ajax_data.length > 0
           series = @process_data(ajax_data)
           console.log(series)
           @render(data.query, series)
        else
           @render_error(data.query)
    )

  process_data: (data) ->
    control_boudries_data = []
    for k in data
      control_boudries_data.push([k.data_date, k.atc_LCL, k.atc_UCL])
   
    series_boundries = {
      name: "atc control series_boundries"
      type: 'areasplinerange'
      data: control_boudries_data
      fillOpacity: .03
      # color: "#8bbc21"
      lineWidth: 0,
      linkedTo: ':previous',
      color: Highcharts.getOptions().colors[0]
      fillOpacity: 0.2
      zIndex: 0
      # '#c0c0c0' 
    }

    console.log(series_boundries)
     
    atc_data = [] 
    trend_data = [] 
    ooc_data = []

    for k in data
      atc_data.push([k.data_date, k.atc_metric])
      trend_data.push([k.data_date, k.atc_trend])
      if k.atc_OOC_flag ==1
        ooc_data.push([k.data_date, k.atc_metric])
 
    series_atc = {
      name: "atc"
      type: 'spline'
      data: atc_data
      zIndex: 2
      # color: 'black'
      lineWidth: 2,
      lineColor: Highcharts.getOptions().colors[0]
      # marker: {
      #   fillColor: 'white',
      #   lineWidth: 2,
      #   lineColor: Highcharts.getOptions().colors[0]
      # }
    
    }

    series_trend = {
      name: "atc trend"
      type: 'spline'
      data: trend_data
      color: '#c0c0c0'
      zIndex: 1
        # '#2f7ed8'  
    }

    series_ooc = {
      name: "OUT OF CONTROL!!"
      data: ooc_data
      zIndex: 4
      lineWidth : 0,
      marker : {
        enabled : true,
        radius : 4
        symbol:'circle'
      },
      color: "red"
        # "#910000"

        # "red"
        # "#df5353"
    }


    # arr = []
    # for k in @seriesTypes
    #   arr.push([])
    # for k in data
    #   console.log(k)
    #   for p, i in @seriesTypes
    #     arr[i].push(
    #       x: k.data_date
    #       y: parseFloat(k[p.column])
    #     )
    # series = []
    # for p, i in @seriesTypes
    #   series.push(
    #     name: p.name
    #     data: arr[i]
    #     cursor: 'pointer'
    #     type: p.type
    #     color: p.color
    #   )
    # series[0].fillOpacity = .05
    # # series[1].fillOpacity = .1
    # series[2].fillOpacity = .1
    # console.log("series", series)
    # return series
    series = [series_boundries,series_atc,series_trend, series_ooc]


    return series


  render_error: (query) ->
    return unless @active
    @controller.trigger('qm-count:sub-content:hide-spin')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )

    #  render: (title, dom, data) =>
    # return unless @active
    # dom.children().remove()
    # @initChart(title, dom, data)
    # this
  

  render: (query, data) ->
    return unless @active
    @controller.trigger('qm-count:sub-content:hide-spin')
    @initChart(query, data)
    this
