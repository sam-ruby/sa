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
      if @router.date_changed or @router.cat_changed or @router.query_segment_changed or (path.query? and path.query != @query) or (path.items? and path.items != @items)
        @query = path.query
        @items = path.items
        @dirty = true

      if path.details == 'sig_comp' and path.query? and path.items?
        @get_items(query: @query, items: @items) if @dirty
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
    signals = {}
    get_signal_names = (child_signal)->
      for signal_id, details of child_signal when !signals[signal_id]?
        signal_mapping = view.signalCollection.where(signal_id: signal_id)
        if signal_mapping.length > 0
          signals[signal_id] =
            signal_name: signal_mapping[0].get('signal_name')
            root: true
        else
          signals[signal_id] =
            signal_name: signal_id
            root: false
        get_signal_names(details.c, false) if details.c?

    @collection.each( (e)->
      signals_json =  e.get('signals_json')
      get_signal_names(signals_json) if signals_json?
    , this)

    signals_sorted = []
    for signal_id, details of signals when details.root == true
      max_signal_items = []
      max_signal_value = 0
      t_score = 0
      values = []
      @collection.each( (e)->
        if e.get('signals_json')? and e.get('signals_json')[signal_id]?
          signal_score = parseFloat(e.get('signals_json')[signal_id].v)
          signal_weight = parseFloat(e.get('signals_json')[signal_id].w)
          if signal_weight? and signal_score?
            t_score = signal_score * signal_weight
          else
            t_score = 0
          values.push(t_score)
          signals[signal_id].values = [] unless signals[signal_id].values?
          signals[signal_id].values.push(t_score)
          if t_score > max_signal_value
            max_signal_value = t_score
            max_signal_items = []
            max_signal_items.push(e)
          else if t_score == max_signal_value
            max_signal_items = []
      )
      if max_signal_items.length == 1
        max_signal_items[0].get('signals_json')[signal_id].max = true
      
      avg_value = 0
      for value in values
        avg_value = avg_value + value
      avg_value = avg_value/values.length

      sq_diff = 0
      for value in values
        # sq_diff = sq_diff + Math.pow(value/(avg_value + 0.00001), 2)
        sq_diff = sq_diff + Math.pow(value - avg_value, 2)
      sq_diff = sq_diff/values.length

      t_obj =
        name: details.signal_name
        id: signal_id
        value: sq_diff
      signals_sorted.push(t_obj)

    signals_sorted.sort((a,b) ->
      if a.value < b.value
        1
      else if a.value > b.value
        -1
      else
        0
    )
    @$el.append( @navBar(title: 'Signal Comparison') )
    @$el.append(@template(
      signals: signals_sorted, items: @collection.toJSON()))

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
   
