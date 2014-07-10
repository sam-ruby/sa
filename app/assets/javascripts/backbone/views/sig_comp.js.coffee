#= require backbone/views/base
class Searchad.Views.SignalComparison extends Searchad.Views.Base
  initialize: (feature) ->
    @collection = new Searchad.Collections.SignalComparison()
    @signalCollection = new Searchad.Collections.SignalMapping()
    @signalCollection.fetch()
    
    @template = JST["backbone/templates/sig_comp"]
    @navBar = JST["backbone/templates/mini_navbar"]
    super()
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'request', @prepare_for_render)
    
    @listenTo(@router, 'route:search', (path, filter) =>
      if @router.date_changed or @router.cat_changed or @router.query_segment_changed or (path.query? and path.query != @query) or (path.items? and path.items != @items) or (path.engine_url? and path.engine_url != @engine_url)
        @query = path.query
        @items = path.items
        @engine_url = path.engine_url
        @dirty = true

      if path.details == 'sig_comp' and path.query? and path.items? and @dirty
        @get_items(
          query: @query
          items: @items
          engine_url: @engine_url
        )
        @controller.send_event('Signal Comparison', @query)
    )
    @$el.tooltip(selector: 'a[data-toggle="tooltip"]')
  
  events: =>
    'click a.go-back-sm': (e) =>
      query_segment = @router.path.search
      @router.update_path(
        "search/#{query_segment}/page/overview", trigger: true)

  get_items: (data) ->
    @collection.get_items(data)

  prepare_for_render: =>
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').css('display', 'block')
  
  render: =>
    view = this
    @dirty = false
    @$el.find('.ajax-loader').hide()
    return if @collection.length == 0
    signals = @collection.at(0).get('signals')
    items = @collection.at(0).get('items')

    @$el.append( @navBar(title: 'Signal Comparison') )
    @$el.append(@template(
      engine_url: @engine_url
      signals: signals
      items: items))
    @$el.find('.signal-section').jstree() if signals.length > 0

  renderBarChart: (data, x_title, y_title, chart_title) ->
    process_data = (data) ->
      cat_data = []
      series_data = []
      for k in data
        cat_data.push(k.cat)
        series_data.push(k.vol)
      [cat_data, series_data]
    
    [cat_data, series_data] = process_data(data)
    
    @$el.highcharts(
      chart:
        type: 'column'
        height: 400
        width: 960
      credits:
        enabled: false
      xAxis:
        categories: cat_data
        title:
          text: x_title
      yAxis:
        title:
          text: y_title
      title:
        text: chart_title
        useHTML: true
        align: "center"
        floating: true
      plotOptions:
        column:
          tooltip:
            headerFormat:
              "<span style='color:{series.color}'>#{x_title}</span>: " +
              "<b>{point.key}</b><br/>"
            pointFormat:
              "<span style='color:{series.color}'>#{y_title}</span>: " +
              "<b>{point.y}</b><br/>"
        series:
          marker:
            enabled: false
            states:
              hover:
                enabled: true
      legend:
        enabled: false
      series: [{
        name: ''
        data: series_data}]
    )
    @$el.find('.ajax-loader').hide()
    @delegateEvents()
   
