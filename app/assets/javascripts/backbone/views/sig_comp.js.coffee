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
    item_ids = []
    get_signal_names = (container, child_signal, root, item_id)->
      for signal_id, details of child_signal
        if !container[signal_id]?
          if root == true
            signal_mapping = view.signalCollection.where(signal_id: signal_id)
            if signal_mapping.length > 0
              signal_name = signal_mapping[0].get('signal_name')
              if details.c?
                signal_name += " (#{details.o})"
              container[signal_id] =
                signal_name: signal_name
          else
            if details.c? and signal_id.match(/^\d$/)
              signal_name = "(#{details.o})"
            else if details.c?
              signal_name = "#{signal_id} (#{details.o})"
            else
              signal_name = signal_id
            container[signal_id] =
              signal_name: signal_name
        
        if container[signal_id]
          if details.v? and details.w?
            signal_score = parseFloat(details.v)
            signal_weight = parseFloat(details.w)
            container[signal_id][item_id] =
              score: signal_score
              weight: signal_weight
              value: signal_score * signal_weight
          else if details.v?
            signal_score = parseFloat(details.v)
            container[signal_id][item_id] =
              score: signal_score
        
        if details.c?
          container[signal_id].children = {} if !container[signal_id].children?
          get_signal_names(container[signal_id].children, details.c, false, item_id)

    @collection.each( (e)->
      signals_json =  e.get('signals_json')
      item_id = e.get('item_id')
      item_ids.push(item_id)
      get_signal_names(signals, signals_json, true, item_id) if signals_json?
    , this)

    signals_sorted = []
    for signal_id, details of signals
      max_signal_items = []
      max_signal_value = 0
      value = 0
      values = []
      for item_id in item_ids
        if details[item_id]?
          value = details[item_id].value
          values.push(value)
          details.values = [] unless details.values?
          details.values.push(value)
          if value > max_signal_value
            max_signal_value = value
            max_signal_item = item_id
          else if value == max_signal_value
            max_signal_item = null
      
      if max_signal_item?
        details[max_signal_item].max = true
      
      avg_value = 0
      for value in values
        avg_value = avg_value + value
      avg_value = avg_value/values.length

      sq_diff = 0
      for value in values
        sq_diff = sq_diff + Math.pow(value - avg_value, 2)
      sq_diff = sq_diff/values.length

      t_obj =
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
    console.log 'Here is the signals sorted ', signals, signals_sorted, item_ids,
      @collection.toJSON()
    @$el.append( @navBar(title: 'Signal Comparison') )
    @$el.append(@template(
      signals: signals
      signals_sorted: signals_sorted
      items: @collection.toJSON()
      item_ids: item_ids))
    @$el.find('.signal-section').jstree()

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
   
