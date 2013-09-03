Searchad.Views.PoorPerforming.Stats ||= {}

class Searchad.Views.PoorPerforming.Stats.IndexView extends Backbone.View
  initialize: (options) ->
    _.bindAll(this, 'render', 'get_items')
    @controller = SearchQualityApp.Controller
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('pp:content-cleanup', @unrender)
    @data = {}
  
  active: false

  seriesTypes: [{
    column: "query_pvr"
    name: I18n.t('perf_monitor.product_view_rate_l')},
    {column: "query_atc"
    name: I18n.t('perf_monitor.add_to_cart_rate_l')},
    {column: "query_con"
    name: I18n.t('perf_monitor.conversion_rate_l')},
    {column: "query_count"
    name: I18n.t('dashboard.query_count_l')},
    {column: 'query_revenue'
    name: 'revenue'}]

  initChart: (query, series) ->
    @$el.highcharts('StockChart',
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
      yAxis: [{
        title:
          text: 'Percent'
        gridLineWidth: 0},
          {title:
            text: 'Count/Revenue'
          opposite: true
          type: 'linear'
          gridLineWidth: 0}]
      title:
        text: ('Query Statistics for ' + query)
        useHTML: true
        align: "center"
        floating: true
      plotOptions:
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
      series: series)
    
  unrender: ->
    @active = false
    @$el.highcharts().destroy()
    @$el.children().remove()

  get_items: (data) ->
    if data and data.query
      @data.query = data.query
    else
      data = @data
    @unrender()
    image =$('<img>').addClass('ajax-loader').attr(
      'src', '/assets/ajax_loader.gif').css('display', 'block')
    @$el.append(image)
    $.ajax(
      url: '/poor_performing/get_query_stats.json'
      data:
        query: data.query
      success: (json, status) =>
        series = @process_data(json)
        @render(data.query, series)
    )

  process_data: (data) ->
    arr = []
    for k in @seriesTypes
      arr.push([])
    for k in data
      for p, i in @seriesTypes
        arr[i].push(
          x: Date.parse(k.query_date)
          y: parseFloat(k[p.column])
        )
    series = []
    for p, i in @seriesTypes
      series.push(
        name: p.name
        data: arr[i]
        cursor: 'pointer'
        type: if i < 3 then 'areaspline' else 'spline'
        yAxis: if i > 2 then 1 else 0)
    
    series[0].fillOpacity = .1
    series[1].fillOpacity = .3
    series

  render: (query, data) ->
    @active = true
    @$el.children().remove()
    @initChart(query, data)
    return this
  
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('img.ajax-loader').hide()
