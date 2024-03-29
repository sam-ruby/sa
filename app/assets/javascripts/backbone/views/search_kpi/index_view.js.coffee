Searchad.Views.SearchKPI||= {}

class Searchad.Views.SearchKPI.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @controller.bind('content-cleanup', @unrender)
    @paid_el = @$el.find(options.paid_dom_selector)
    @unpaid_el = @$el.find(options.unpaid_dom_selector)

  active: false

  seriesTypes: [{
    column: "query_pvr"
    name: I18n.t('perf_monitor.product_view_rate_l')},
    {column: "query_atc"
    name: I18n.t('perf_monitor.add_to_cart_rate_l')},
    {column: "query_con"
    name: I18n.t('perf_monitor.conversion_rate_l')},
    {column: "query_count"
    name: I18n.t('dashboard.query_count_l')}]

  initChart: (title, dom, series) =>
    that = this
    dom.highcharts('StockChart',
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
            text: 'Query Count'
          opposite: true
          type: 'linear'
          gridLineWidth: 0}]
      title:
        text: title
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
        areaspline:
          events:
            click: (e) ->
              that.goto_query_analysis(e.point.x) if e.point.x?
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
    
    
  goto_query_analysis: (date_in_millisecs) ->
    new_date = (new Date(date_in_millisecs)).toString('M-d-yyyy')
    SearchQualityApp.Router.navigate(
      "/search_rel/filters/date/#{new_date}", trigger: true)

  get_items: ->
    @active = true
    image =$('<img>').addClass('ajax-loader').attr(
      'src', '/assets/ajax_loader.gif').css('display', 'block')
    @paid_el.append(image)

    $.ajax(
      url: '/search_kpi/get_data.json'
      success: (json, status) =>
        paid_series = @process_data(json.paid)
        console.log("paid_series", paid_series)
        @render('Paid Traffic', @paid_el, paid_series)
        unpaid_series = @process_data(json.unpaid)
        @render('Unpaid Traffic', @unpaid_el, unpaid_series)
    )

  process_data: (data) ->
    arr = []
    for k in @seriesTypes
      arr.push([])
    for k in data
      for p, i in @seriesTypes
        arr[i].push(
          x: k.date
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
    
    series[0].fillOpacity = .05
    series[1].fillOpacity = .1
    series[2].fillOpacity = .2
    series

  render: (title, dom, data) =>
    return unless @active
    dom.children().remove()
    @initChart(title, dom, data)
    this
  
  unrender: =>
    @active = false
    @$el.children().not(@options.paid_dom_selector).not(
      @options.unpaid_dom_selector).remove()
    @paid_el.highcharts().destroy() if @paid_el.highcharts()
    @unpaid_el.highcharts().destroy() if @unpaid_el.highcharts()
    @paid_el.children().remove()
    @unpaid_el.children().remove()
