#= require backbone/views/base
Searchad.Views.Metrics ||= {}

class Searchad.Views.Metrics.Index extends Searchad.Views.Base
  initialize: (feature) ->
    super()
    if @collection? and @grid_cols?
      @listenTo(@collection, 'backgrid:refresh', @post_refresh)
      @listenTo(@collection, 'request', @prepare_for_table)
      @collection.winning = false
      @winning = false
      @init_table()
    else if @collection? and !@grid_cols?
      @listenTo(@collection, 'reset', @render)

    @show_query_mode = false
    
    @listenTo(@router, 'route:search', (path, filter) =>
      if @router.date_changed or @router.cat_changed or @router.query_segment_changed
        @dirty = true
      if path.page == feature and !path.details?
        @cleanup()
        @renderTable()
        @get_items() if @dirty
    )
    
    @$el.find('.carousel').on('slid', =>
      active_slide = @$el.find('.carousel-inner div.active')
      if active_slide.hasClass('distribution')
        @$el.find('.tab-holder li.active').removeClass('active')
        @$el.find('.tab-holder li.distribution').addClass('active')
      else if active_slide.hasClass('timeline')
        @$el.find('.tab-holder li.active').removeClass('active')
        @$el.find('.tab-holder li.timeline').addClass('active')
    )

  events: =>
    'click a.go-back-sm': (e) =>
      query_segment = @router.path.search
      @router.update_path(
        "search/#{query_segment}/page/overview", trigger: true)

    'click li.distribution a': (e) =>
      e.preventDefault()
      $(e.target).parents('ul').children('li').removeClass('active')
      $(e.target).parents('li').addClass('active')
      @$el.find('.carousel').carousel(0)
      @$el.find('.carousel').carousel('pause')
      # $('html, body').animate({scrollTop: @$el.offset().top}, 1000)
   
    'click a.brand': (e) =>
      e.preventDefault()
      window.scrollTo(0, 0)
   
    'click li.timeline a': (e) =>
      e.preventDefault()
      $(e.target).parents('ul').children('li').removeClass('active')
      $(e.target).parents('li').addClass('active')
      @$el.find('.carousel').carousel(1)
      @$el.find('.carousel').carousel('pause')
      # div = @$el.parent().find('div.timeline')
      # $('html, body').animate({scrollTop: div.offset().top}, 1000)

    'click div.show-others a': 'show_other_queries'

  init_table: () =>
    @grid = new Backgrid.Grid(
      columns: @grid_cols()
      collection: @collection
      emptyText: 'No Data'
      className: 'winners-grid'
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )

  cleanup: =>
    if @$el.attr('id') == 'metric'
      @$el.find('.tab-holder').children().not('.ajax-loader').remove()
      @$el.find('.distribution.item').highcharts().destroy() if @$el.find('.distribution.item').highcharts()
    else
      @$el.children().not('.ajax-loader').remove()
      @winning = false
      @collection.winning = @winning
    
  get_items: (data) =>
    @dirty = false
    @$el.find('.tab-holder').empty()
    @$el.find('.tab-holder').append(@navBar)
    @collection.get_items(data)

  toggle_tab: (e) =>
    $(e.target).parents('ul').find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')
    if @$el.find('thead th.descending').length > 0
      @$el.find('thead th.descending').removeClass('descending').addClass('ascending')
    else
      @$el.find('thead th.ascending').removeClass('ascending').addClass('descending')

  prepare_for_render: =>
    @$el.find('.ajax-loader').css('display', 'inline-block')

  prepare_for_table: =>
    @$el.find('.ajax-loader').css('display', 'inline-block')

  show_query: =>
    return if @show_query_mode
    that = this
    trs = @$el.find('table.backgrid tbody tr').not('.selected')
    trs.addClass('visually-hidden')
    @show_query_mode = true

  show_other_queries: (e) =>
    e.preventDefault()
    @$el.find('table.backgrid tbody tr.visually-hidden').removeClass(
      'visually-hidden')

  post_refresh: ->
    @$el.find('.ajax-loader').hide()
  
  renderTable: =>
    if @winning
      div = @tableCaption(tab: 'winners')
    else
      div = @tableCaption(tab: 'loosers')
    @$el.append(div)
    @$el.append( @grid.render().$el )
    @$el.append( @paginator.render().$el )
    @$el.append( @export_csv_button() )
    @delegateEvents()
    this
  
  renderLineChart: (data, y_title, chart_title) =>
    @dirty = false
    seriesTypes = [{
      column: 'score'
      name: y_title}]
    
    series = []
    arr = []
    
    for k in seriesTypes
      arr.push([])
    for k in data
      for p, i in seriesTypes
        arr[i].push(
          x: k.data_date
          y: parseFloat(k[p.column])
        )
    for p, i in seriesTypes
      series.push(
        id: p.column
        name: p.name
        data: arr[i]
        cursor: 'pointer'
        type: 'spline'
        yAxis: 0)
    
    series[0].fillOpacity = .1
    @$el.highcharts(
      chart:
        alignTicks: false
        height: 400
        width: 960
      rangeSelector:
        selected: 0
      credits:
        enabled: false
      xAxis:
        type: 'datetime'
        labels:
          formatter: ->
            Highcharts.dateFormat('%b %e', @value)
      yAxis: {
        title:
          text: y_title
        gridLineWidth: 0}
      title:
        text: chart_title
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
        enabled: false
      series: series)
     
  renderBarChart: (data, x_title, y_title, chart_title) =>
    @dirty = false
    process_data = (data) ->
      cat_data = []
      series_data = []
      for k in data
        cat_data.push(k.cat)
        series_data.push(k.vol)
      [cat_data, series_data]
    
    [cat_data, series_data] = process_data(data)
    
    # @controller.trigger('hide_summary')
    @$el.find('.distribution.item').highcharts(
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
    @$el.find('.carousel').show()
    @$el.find('.carousel').carousel(0)
    @$el.find('.carousel').carousel('pause')
    @navBarDiv = @$el.find('.second-navbar')
    @delegateEvents()
    
  render_error: (query) ->
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available") )


