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
    atc_data = [] 
    trend_data = [] 
    ooc_data_good = []
    ooc_data_bad = []

    for k in data
      control_boudries_data.push([k.data_date, k.atc_LCL, k.atc_UCL])
      atc_data.push([k.data_date, k.atc_metric])
      trend_data.push([k.data_date, k.atc_trend])
      # process red or green dot for the ooc flag
      if k.atc_OOC_flag ==1
        ooc_data_good.push([k.data_date, k.atc_metric])
      if k.atc_OOC_flag == -1
        ooc_data_bad.push([k.data_date, k.atc_metric])

    series_boundries = {
      name: "atc control series_boundries"
      type: 'areasplinerange'
      data: control_boudries_data
      tooltip: {
        crosshairs: true,
        shared: true
      },
      fillOpacity: .03
      lineWidth: 0,
      color: Highcharts.getOptions().colors[0]
      fillOpacity: 0.2
      zIndex: 0
    }
     
    series_atc = {
      name: "atc"
      type: 'spline'
      data: atc_data
      zIndex: 2
      lineWidth: 2,
      lineColor: Highcharts.getOptions().colors[0]
    }

    series_trend = {
      name: "atc trend"
      type: 'spline'
      data: trend_data
      color: '#c0c0c0'
      zIndex: 1
    }

    series_ooc_bad = {
      name: "OUT OF CONTROL- Bad!!"
      data: ooc_data_bad
      zIndex: 4
      lineWidth : 0,
      marker : {
        enabled : true,
        radius : 4
        symbol:'circle'
      },
      color: "red"
    }

    series_ooc_good = {
      name: "OUT OF CONTROL- Good or possible out of stock"
      data: ooc_data_good
      zIndex: 4
      lineWidth : 0,
      marker : {
        enabled : true,
        radius : 4
        symbol:'circle'
      },
      color: "green"
    }

    series = [series_boundries,series_atc,series_trend, series_ooc_bad, series_ooc_good]

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
