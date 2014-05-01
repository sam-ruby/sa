#= require backbone/views/base
class Searchad.Views.SignalComparison extends Searchad.Views.Base
  initialize: (feature) ->
    @collection = new Searchad.Collections.SignalComparison()
    @template = JST["backbone/templates/sig_comp"]
    @navBar = JST["backbone/templates/mini_navbar"]
    super()
    @listenTo(@collection, 'reset', @render)
    @active = false
    
    @listenTo(@router, 'route:search', (path, filter) =>
      if path.details == 'sig_comp' and path.query? and path.items?
        if @router.date_changed or @router.cat_changed or !@active or @router.query_segment_changed
          @get_items(query: path.query, items: path.items)
      else
        @cleanup() if @active
        @active = false
    )
  signal_lookup:
    base:
      name: 'Base'
    ce:
      name: 'CE'
    color_boost:
      name: 'Color Boost'
    di:
      name: 'DI'
    dp:
      name: 'DP'
    hero_item:
      name: 'Hero Item'
    imageless_demotion:
      name: 'Imageless Demotion'
  
  events: =>
    'click a.go-back-sm': (e) =>
      query_segment = @router.path.search
      @router.update_path(
        "search/#{query_segment}/page/overview", trigger: true)

  get_items: (data) ->
    @collection.get_items(data)

  render: =>
    return if @collection.length == 0
    @$el.children().not('.ajax-loader').remove()
    signals = {}

    @collection.each( (e)->
      signals_json =  e.get('signals_json')
      if signals_json?
        for signal_id, values of signals_json when !signals[signal_id]?
          signals[signal_id] = @signal_lookup[signal_id]
    , this)
    console.log 'Singal ', signals
    @$el.append( @navBar(title: 'Signal Comparison') )
    @$el.append(@template(signals: signals, items: @collection.toJSON()))

  renderBarChart: (data, x_title, y_title, chart_title) ->
    return unless @active
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
   
