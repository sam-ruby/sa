Searchad.Views.QueryMonitoring ||= {}
Searchad.Views.QueryMonitoring.Count ||= {}
Searchad.Views.QueryMonitoring.Count.Stats ||= {}

class Searchad.Views.QueryMonitoring.Count.Stats.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('qm-count:sub-content-cleanup', @unrender)
    @data = {}
    @active = false

  initChart: (query, series, ucl) ->
    @$el.highcharts('StockChart',
      chart:
        alignTicks: false
        type: 'areaspline'
      rangeSelector:
        selected: 1
      credits:
        enabled: false
      xAxis:
        type: 'datetime'
        labels:
          formatter: ->
            Highcharts.dateFormat('%b %e', @value)
      title:
        text: ('Daily Query Count Monitoring for ' + query)
        useHTML: true
        align: "center"
        floating: true
      plotOptions:
        areaspline:
          fillOpacity: .1
        series:
          marker:
            enabled: false
            states:
              hover:
                enabled: true
      legend:
        enabled: true
        layout: 'horizontal'
        align: 'center'
        verticalAlign: 'bottom'
        borderWidth: 0
      series: [
        name: 'Query Count'
        data: series
      ]
      yAxis:
        title:
          text: 'Query Count'
        type: 'logarithmic'
        minorTickInterval: 1
        min: 1
        plotLines: [{
          events:
            mouseover: (e) ->

          color: 'red'
          label:
            text: 'Alarm Threshold'
            align: 'right'
            y: 12
            x: 0
          dashStyle: 'LongDash'
          width: 2
          value: ucl
        }
        ]
    )
    
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
      url: '/monitoring/count/get_query_stats.json'
      data:
        query: data.query
      success: (ajax_data, status) =>
        if ajax_data.stats and ajax_data.stats.length > 0
          series = @process_data(ajax_data.stats)
          @render(data.query, series, ajax_data.baseline_ucl)
        else
          @render_error(data.query)
    )

  process_data: (data) ->
    series = []
    for k in data
      series.push(
        x: k.query_date
        y: k.query_count)
    series

  render_error: (query) ->
    return unless @active
    @controller.trigger('qm-count:sub-content:hide-spin')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )

  render: (query, data, ucl) ->
    return unless @active
    @controller.trigger('qm-count:sub-content:hide-spin')
    @initChart(query, data, ucl)
    this
