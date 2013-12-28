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

  initChart: (title, series, type) =>
    # title = "ATC metric monitoring for " + title
    that = this
    dom = "#" + type + "-stats"
    console.log(dom)
    $(dom).highcharts('StockChart',
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
          text: 'atc metric (%)'
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

      legend:
        enabled: true
        layout: 'horizontal'
        align: 'center'
        verticalAlign: 'bottom'
        borderWidth: 0
      series: series)

  unrender: =>
    @active = false
    # clear the three stats
    $("#con-stats").empty()
    # .highcharts().destroy() if @$el.highcharts()   
    $("#pvr-stats").empty()
    $("#atc-stats").empty()
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
        stats_type: "all"#data.stats_type
      success: (ajax_data, status) =>
        if ajax_data and ajax_data.length > 0
           series = @process_one_type_data(ajax_data, "atc")
           console.log(series)
           @render("conversion monitoring for " + data.query, @process_one_type_data(ajax_data, "con"), "con")
           @render("pvr monitoring for " + data.query, @process_one_type_data(ajax_data, "pvr"), "pvr")
           @render("atc monitoring for " + data.query, @process_one_type_data(ajax_data, "atc"),"atc")

        else
           @render_error(data.query)
    )

  # available types :atc, pvr, con
  process_one_type_data: (data, type) ->
    # generate variable name
    metric = type + "_metric"
    LCL = type + "_LCL"
    UCL = type + "_UCL"
    trend = type + "_trend"
    ooc_flag = type + "_OOC_flag"
    # data series for drawing graph
    control_boudries_data = []
    atc_data = [] 
    trend_data = [] 
    ooc_data_good = []
    ooc_data_bad = []

    for k in data
      control_boudries_data.push([k.data_date, k[LCL], k[UCL]])
      atc_data.push([k.data_date, k[metric]])
      trend_data.push([k.data_date, k[trend]])
      # process red or green dot for the ooc flag
      if k[ooc_flag] ==1
        ooc_data_good.push([k.data_date, k[metric]])
      if k[ooc_flag] == -1
        ooc_data_bad.push([k.data_date, k[metric]])

    series_boundries = {
      name: type + " out of control series_boundries"
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
      lineColor: Highcharts.getOptions().colors[0]
    }

    series_trend = {
      name: type + "trend"
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

    series = [series_boundries,series_metric,series_trend, series_ooc_bad, series_ooc_good]
    return series


  render_error: (query) ->
    return unless @active
    @controller.trigger('qm-count:sub-content:hide-spin')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )

  render: (title, data, type) ->
    return unless @active
    @controller.trigger('qm-count:sub-content:hide-spin')
    @initChart(title, data, type)
    this
