Searchad.Views.QueryMonitoring ||= {}
Searchad.Views.QueryMonitoring.Metric ||= {}
Searchad.Views.QueryMonitoring.Metric.Stats ||= {}

class Searchad.Views.QueryMonitoring.Metric.Stats.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('qm:sub-content:cleanup', @unrender)
    @data = {}
    @active = false

  initChart: (title, series, type) =>
    # title = "ATC metric monitoring for " + title
    that = this
    dom = "#" + type + "-stats"
    $(dom).highcharts('StockChart',
      chart:
        alignTicks: false
      rangeSelector:
        selected: 0
      credits:
        enabled: false
      xAxis:
        type: 'datetime'
        labels:
          formatter: ->
            Highcharts.dateFormat('%b %e', @value)
      # single side y value
      yAxis: [{
        title:
          text: type + ' metric (%)'
        gridLineWidth: 0}]
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

      legend:
        enabled: true
        layout: 'horizontal'
        align: 'center'
        verticalAlign: 'bottom'
        borderWidth: 0
      series: series)

  unrender: =>
    @active = false
    @$el.children().not('#con-stats, #pvr-stats, #atc-stats').remove()
    # clear the three stats
    $("#con-stats").empty()
    $("#pvr-stats").empty()
    $("#atc-stats").empty()
    @controller.trigger('qm:sub-content:hide-spin')

  
  get_items: (data) =>
    @active = true
    @$el.highcharts().destroy() if @$el.highcharts()
    @controller.trigger('qm:sub-content:show-spin')
    @$el.find('.ajax-loader').show()
    $.ajax(
      url: '/monitoring/metrics/get_query_stats.json'
      data:
        query: data.query
        stats_type: "all" #data.stats_type
      success: (ajax_data, status) =>
        # save the data to the @data, so that next time before fetch, detect if data has changed.
        @data.query = data.query
        @data.stats_type = data.stats_type
        if ajax_data and ajax_data.length > 0
           @render("conversion monitoring for " + data.query, @process_one_type_data(ajax_data, "con"), "con")
           @render("pvr monitoring for " + data.query, @process_one_type_data(ajax_data, "pvr"), "pvr")
           @render("atc monitoring for " + data.query, @process_one_type_data(ajax_data, "atc"),"atc")

        else
           @render_error(data.query)
    )


  render: (title, data, type) ->
    return unless @active
    @controller.trigger('qm:sub-content:hide-spin')
    @initChart(title, data, type)
    this


  render_error: (query) ->
    return unless @active
    @controller.trigger('qm:sub-content:hide-spin')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )

  
  # available types :atc, pvr, con
  process_one_type_data: (data, type) ->
    # generate variable name
    metric = type + "_metric"
    LCL = type + "_LCL"
    UCL = type + "_UCL"
    trend = type + "_trend"
    ooc_flag = type + "_OOC_flag"
    trend_flag = type + "_trend_flag"
    # data series for drawing graph
    control_boudries_data = []
    atc_data = [] 
    trend_data = [] 
    ooc_data_bad = []
    ooc_data_down_trend = []

    for k in data
      control_boudries_data.push([k.data_date, k[LCL], k[UCL]])
      atc_data.push([k.data_date, k[metric]])
      trend_data.push([k.data_date, k[trend]])
      # process red or green dot for the ooc flag
      # only when the trend is not downwarding and the ooc_flag is 1, it consider as good ooc
      if k[ooc_flag] == -1
        ooc_data_bad.push([k.data_date, k[metric]])
      if k[trend_flag] ==1
        ooc_data_down_trend.push([k.data_date, k[trend]])

    series_boundries = {
      name: "Out of control boundries"
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
     
    series_metric = {
      name: type
      type: 'spline'
      data: atc_data
      zIndex: 2
      lineWidth: 2,
      color: Highcharts.getOptions().colors[0]
    }

    series_trend = {
      name: type + " trend"
      type: 'spline'
      data: trend_data
      zIndex: 1
      color: '#c0c0c0'
    }

   # ooc bad indicates the bad ooc
    series_ooc_bad = {
      name: "Out of control, deviates from prediction"
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
    # down_trend indicates it's a downward trending
    series_down_trend = {
      name: "Downward Trending"
      data: ooc_data_down_trend
      zIndex: 4
      lineWidth : 0,
      marker : {
        enabled : true,
        radius : 4
        symbol:'circle'
      },
      color: "orange"
    }


    series = [series_boundries,series_metric,series_trend, series_down_trend, series_ooc_bad]
    return series
