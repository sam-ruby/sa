#= require backbone/views/base
Searchad.Views.Metrics ||= {}

class Searchad.Views.Metrics.Index extends Searchad.Views.Base
  initialize: (feature) ->
    super()
    if @collection?
      @listenTo(@collection, 'reset', @render)
      @listenTo(@collection, 'request', @prepare_for_render)
      @winning = true

    @active = false
    @show_query_mode = false
    
    @listenTo(@router, 'route', (route, params) =>
      if route == 'search' and @router.sub_task == feature
        @get_items() unless @active
      else
        @active = false
        @$el.children().not('.ajax-loader').not(
          '.tab-holder').not('.carousel').remove()
    )
    """
    $(document).scroll((e) =>
      return unless @active
      return unless @navBarDiv?
      topPosition = @$el.position().top
      navBarWidth = @navBarDiv.width()
      navBarHeight = @navBarDiv.parent().height()

      if window.pageYOffset >= topPosition
        @navBarDiv.parent().height(navBarHeight)
        @navBarDiv.addClass('fixed-navbar')
        @navBarDiv.css('width', navBarWidth)
      else if window.pageYOffset < topPosition and @navBarDiv.hasClass('fixed-navbar')
        @navBarDiv.removeClass('fixed-navbar')
        @navBarDiv.css('width', '')
    )
    """

  events: =>
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
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )

  get_items: (data) =>
    @active = true
    @collection.get_items(data)

  toggle_tab: (e) =>
    $(e.target).parents('caption').find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')

  prepare_for_render: =>
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

  renderTable: =>
    return unless @active
    @$el.find('.ajax-loader').hide()
    if @collection.size() == 0
      @$el.prepend( @grid.render() )
      return
    else
      @$el.prepend( @paginator.render().$el )
      @$el.prepend( @grid.render().$el )
  
    if @winning
      div = @tableCaption(tab: 'winners')
    else
      div = @tableCaption(tab: 'loosers')
    @$el.find('table.backgrid').append(
      "<caption class='win-loose-head'>#{ div }</caption>" )

    @$el.append( @export_csv_button() ) unless @$el.find(
      '.export-csv').length > 0
    debugger
    @$el.find('td a.query').first().trigger('click')
    @delegateEvents()
    this
  
  unrender: =>
    @active = false
    @$el.highcharts().destroy() if @$el and @$el.highcharts()
    
  renderLineChart: (data, y_title, chart_title) ->
    return unless @active
    
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

    @$el.find('.distribution').highcharts(
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
    @$el.find('.tab-holder').append( "<div>#{ @navBar }</div>" )
    @navBarDiv = @$el.find('.second-navbar')
    @delegateEvents()
    
  render_error: (query) ->
    return unless @active
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available") )


