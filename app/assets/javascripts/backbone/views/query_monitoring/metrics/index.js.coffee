Searchad.Views.QueryMonitoring ||= {}
Searchad.Views.QueryMonitoring.Metric ||= {}

class Searchad.Views.QueryMonitoring.Metric.IndexView extends Backbone.View
  initialize: (options) =>
    console.log("init query monitoring metric")
    # @trigger = false
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection = new Searchad.Collections.QueryMonitoringMetricCollection()
    # @$filter = @$el.find(options.el_filter)
    # @filterAdded = false
    @initTable()
    # @$el.find('.ajax-loader').hide()
    
    # @controller.bind('date-changed', =>
    #   @get_items(trigger: true) if @active)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('reset', @render)
    @collection.bind('request', =>
      # @unrender_search_results()
      @$el.find('.ajax-loader').css('display', 'block')
      @controller.trigger('qm-count:sub-content-cleanup')
    )
    # Utils.InitExportCsv(this, "/monitoring/count/get_words.csv")
    @undelegateEvents()
    @active = false

  events: =>
    # 'click .filter': 'filter'
    # 'click .reset': 'reset'
    # 'submit': 'filter'
    # 'click .export-csv a': (e) ->
    #   date = @controller.get_filter_params().date
    #   fileName = "query_count_monitoring_#{date}.csv"
    #   data =
    #     date: date
    #   data['query'] = @collection.query if @collection.query
    #   @export_csv($(e.target), fileName, data)
  render: =>
    return unless @active
    @$el.find('.ajax-loader').hide()
    return @render_error(@collection.query) if @collection.size() == 0
    # unless @filterAdded
    #   @$filter.append(@initFilter()())
    #   @filterAdded = true
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @paginator.render().$el)
    # @$el.append( @export_csv_button() )
    @delegateEvents()
    
    # if @trigger
    #   @trigger = false
    #   @$el.find('td a.query').first().trigger('click')
    this

  unrender: =>
    @active = false
    # @unrender_search_results()
    # @clear_filter()
    @undelegateEvents()
    this


  initTable: () =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )
  


  get_items: (data) =>

    console.log("get_items_in query monitoring metrics", data)
    @active = true
    @$el.find('.ajax-loader').css('display', 'block')
    # if data and data.query
    #   @collection.query = data.query
    # else
    #   @collection.query = null
    @collection.get_items()
    @trigger = true

  
  # unrender_search_results: =>
  #   @$el.children().not('.ajax-loader, #' + @$filter.attr('id')).remove()
  #   @$el.find('.ajax-loader').hide()
  


  render_error: (query) ->
    if query?
      msg = "No data available for #{query}"
    else
      msg = "No data available"
    @$el.append($('<span>').addClass('label label-important').append(msg))


  gridColumns:  ->
    that = this
    class QueryCell extends Backgrid.Cell
      controller: SearchQualityApp.Controller
      router: SearchQualityApp.Router

      events:
        'click': 'handleQueryClick'

      handleQueryClick: (e) =>
        e.preventDefault()
        query = $(e.target).text()
        $(e.target).parents('table').find('tr.selected').removeClass('selected')
        $(e.target).parents('tr').addClass('selected')
        console.log('click')
        that.controller.trigger('qm-metric:stats',
          query: query
          view: 'daily')
        new_path = 'query_monitoring/metrics/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)

      render: ->
        value = @model.get(@column.get('name'))
        formatted_value = '<a class="query" href="#">' + value + '</a>'
        @$el.html(formatted_value)
        @delegateEvents()
        return this
    
    columns = [{
    name: 'query',
    label: I18n.t('query'),
    editable: false,
    cell: QueryCell},
    {name: 'count',
    label: 'Query Count',
    editable: false,
    cell: 'integer',
    headerCell: 'custom'},
    {name: 'atc',
    label: 'Add to Cart Rage',
    editable: false,
    cell: 'number'},
    {name: 'atc_trend_score',
    label: 'ATC Trend Score',
    editable: false,
    cell: 'number',
    },
    {name: 'atc_ooc_score',
    label: 'ATC Out of Control Score',
    editable: false,
    cell: 'number',
    }
    ]

    columns


  # clear_filter: =>
  #   @$filter.children().remove()

      # initFilter: =>
  #   _.template('<div class="input-prepend input-append filter-box"><button class="btn btn-primary filter">Filter</button><form><input type="text" placeholder="Type to filter results"/></form><button class="btn btn-primary reset">Reset</button></div>')
 
  # filter: (e) =>
  #   e.preventDefault()
  #   query = @$el.find(".filter-box input[type=text]").val()
  #   @collection.query = query
  #   if query
  #     @collection.get_items()
  #     @active = true
  #     @trigger = true

  # reset: (e) =>
  #   e.preventDefault()
  #   @router.update_path('/search_rel')
  #   @$el.find(".filter-box input[type=text]").val('')
  #   @collection.query = null
  #   @active = true
  #   @collection.get_items()
  #   @trigger = true
