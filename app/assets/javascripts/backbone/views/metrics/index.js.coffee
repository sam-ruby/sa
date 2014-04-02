Searchad.Views.Metrics ||= {}

class Searchad.Views.Metrics.Index extends Backbone.View
  initialize: (feature) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
  
    if @collection?
      @listenTo(@collection, 'reset', @render)
      @listenTo(@collection, 'request', @prepare_for_render)
      @winning = true

    @active = false
    
    @listenTo(@router, 'route', (route, params) =>
      @$el.children().not('.ajax-loader').remove() if @active
      if route == 'search' and @router.sub_task == feature
        @$el.children().not('.ajax-loader').remove()
        @get_items()
      else
        @active = false
    )

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

    super()

  events: =>
    'click caption .winners a': (e) =>
      e.preventDefault()
      @winning = true
      @toggle_tab(e)
      @active = true
      @collection.get_items(winning: true)

    'click caption .loosers a': (e) =>
      e.preventDefault()
      @winning = false
      @toggle_tab(e)
      @active = true
      @collection.get_items(winning: false)
    
    'click a.distribution': (e) =>
      e.preventDefault()
      $('html, body').animate({scrollTop: @$el.offset().top}, 1000)
   
    'click a.brand': (e) =>
      e.preventDefault()
      window.scrollTo(0, 0)
   
    'click a.winners': (e) =>
      e.preventDefault()
      $(e.target).parents('ul').children('li').removeClass('active')
      $(e.target).parents('li').addClass('active')
      div = @$el.parent().children('div.winners')
      $('html, body').animate({scrollTop: div.offset().top}, 1000)
    
    'click a.timeline': (e) =>
      e.preventDefault()
      $(e.target).parents('ul').children('li').removeClass('active')
      $(e.target).parents('li').addClass('active')
      div = @$el.parent().children('div.timeline')
      $('html, body').animate({scrollTop: div.offset().top}, 1000)

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
    @collection.get_items()

  toggle_tab: (e) =>
    $(e.target).parents('caption').find('a').remove()
    winners = @$el.find('span.winners')
    loosers = @$el.find('span.loosers')
    winners.empty()
    loosers.empty()

    if @winning
      loosers.append('<a href="#">Loosers</a>')
      winners.append('Winners')
    else
      winners.append('<a href="#">Winners</a>')
      loosers.append('Loosers')

  prepare_for_render: =>
    @$el.find('.ajax-loader').css('display', 'inline-block')

  renderTable: =>
    return unless @active
    @$el.find('.ajax-loader').hide()
    if @collection.size() == 0
      @$el.prepend( @grid.render() )
      return
    else
      @$el.prepend( @paginator.render().$el )
      @$el.prepend( @grid.render().$el )
   
    unless @$el.find('caption.metrics-summary-head').length > 0
      if @winning == true
        @$el.find('table.backgrid').append(
          """
          <caption class="metrics-summary-head">
          <span class="winners">Winners</span>
          <span class="loosers">
          <a href="#">Loosers</a></span>
          </caption>
        """
        )
      else
        @$el.find('table.backgrid').append(
          """
          <caption class="metrics-summary-head">
          <span class="winners">
            <a href="#">Winners</a>
          </span>
          <span class="loosers">Loosers</span>
          </caption>
        """
        )
    @$el.append( @export_csv_button() ) unless @$el.find(
      '.export-csv').length > 0
    @delegateEvents()
    this
  
  unrender: =>
    @active = false
    @$el.highcharts().destroy() if @$el and @$el.highcharts()
    
  init_cols: ->
    that = this
    class @SortedHeaderCell extends Backgrid.HeaderCell
      initialize: (options) ->
        super(options)
        @direction('descending')
        @$el.css('text-align', 'right')

    class @NumericHeaderCell extends Backgrid.HeaderCell
      initialize: (options) ->
        super(options)
        @$el.css('text-align', 'right')

    class @QueryHeaderCell extends Backgrid.HeaderCell
      initialize: (options) ->
        super(options)
        @$el.css('width', '30%')

    class @QueryCell extends Backgrid.CADQueryCell
      handleQueryClick: (e) ->
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = @model.get('query')
        that.controller.trigger('search:sub-content',
          query: query
          view: 'daily'
        )
        new_path = 'search_rel/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)
        false

  renderLineChart: (data, title, series_name) ->
    return unless @active
    
    seriesTypes = [{
      column: "score"
      name: series_name}]
    
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
          text: 'Score'
        gridLineWidth: 0}
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
      legend:
        enabled: true
        layout: 'horizontal'
        align: 'center'
        verticalAlign: 'bottom'
        borderWidth: 0
      series: series)
     
  renderBarChart: (data, y_title, chart_title, series_name) ->
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
      credits:
        enabled: false
      xAxis:
        categories: cat_data
      yAxis:
        title:
          text: 'Query Count'
      title:
        text: 'Query Distribution'
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
      series: [{
        name: 'Conversion Relevance Correlation Score'
        data: series_data}]
    )
    @$el.prepend( "<div>#{ @navBar }</div>" )
    @navBarDiv = @$el.find('.second-navbar')
    
  render_error: (query) ->
    return unless @active
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available") )


