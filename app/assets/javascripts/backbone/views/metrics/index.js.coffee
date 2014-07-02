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
      @feature = feature
      Utils.InitExportCsv(this)
      @init_table()
      #@grid.sort('score', 'descending')

    else if @collection? and !@grid_cols?
      @listenTo(@collection, 'reset', @render)

    @show_query_mode = false
    
    @listenTo(@router, 'route:search', (path, filter) =>
      if @router.date_changed or @router.cat_changed or @router.query_segment_changed
        @dirty = true
      if (((feature instanceof Array) and (path.page in feature)) or (
        path.page == feature)) and !path.details?
        window.scrollTo(0, 0)
        @cleanup()
        @renderTable()
        @get_items() if @dirty
    ) if feature?

  events: =>
    events = {}
    events['click a.go-back-sm'] = (e) =>
      query_segment = @router.path.search
      @router.update_path(
        "search/#{query_segment}/page/overview", trigger: true)

    events['click a.brand'] = (e) =>
      e.preventDefault()
      window.scrollTo(0, 0)
   
    events['click li.timeline a'] = (e) =>
      e.preventDefault()
      $(e.target).parents('ul').children('li').removeClass('active')
      $(e.target).parents('li').addClass('active')
      @$el.find('.carousel').carousel(1)
      @$el.find('.carousel').carousel('pause')
      # div = @$el.parent().find('div.timeline')
      # $('html, body').animate({scrollTop: div.offset().top}, 1000)
   
    if (@feature instanceof Array)
      for feature in @feature
        events["click .#{feature}-oppt-csv a"] = (e) =>
          params = @controller.get_filter_params()
          data =
            date: params.date
            query_segment: params.query_segment
            cat_id: params.cat_id
            metrics_name: params.metrics_name
            winning: false
            page: 1
            per_page: 4000
          @export_csv($(e.target), data)
    else
      events["click .#{@feature}-oppt-csv a"] = (e) =>
        params = @controller.get_filter_params()
        data =
          date: params.date
          query_segment: params.query_segment
          cat_id: params.cat_id
          metrics_name: params.metrics_name
          winning: false
          page: 1
          per_page: 4000
        @export_csv($(e.target), data)


    events['click div.show-others a'] =  'show_other_queries'
    events

  init_table: () =>
    cols = @grid_cols()
    @grid = new Backgrid.Grid(
      columns: cols
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
    else
      @$el.children().not('.ajax-loader').remove()
      @winning = false
      @collection.winning = @winning
    
  get_items: (data) =>
    @dirty = false
    @$el.find('.tab-holder').empty()
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
  
  render_error: (query) ->
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available") )
