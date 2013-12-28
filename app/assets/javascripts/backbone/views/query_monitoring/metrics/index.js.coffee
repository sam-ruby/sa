Searchad.Views.QueryMonitoring ||= {}
Searchad.Views.QueryMonitoring.Metric ||= {}

class Searchad.Views.QueryMonitoring.Metric.IndexView extends Backbone.View
  initialize: (options) =>
    console.log("init query monitoring metric")
    # @trigger = false
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection = new Searchad.Collections.QueryMonitoringMetricCollection()
    @$filter = @$el.find(options.el_filter)
    # @filterAdded = false
    @initTable()
    # @$el.find('.ajax-loader').hide()
    
    @controller.bind('date-changed', =>
      @get_items(trigger: true) if @active)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('reset', @render)
    @collection.bind('request', =>
      @unrender_search_results()
      @$el.find('.ajax-loader').css('display', 'block')
      @controller.trigger('qm-count:sub-content-cleanup')
    )
    # Utils.InitExportCsv(this, "/monitoring/count/get_words.csv")
    @undelegateEvents()
    @active = false

  events: =>
    'click .filter': 'filter'
    'click .reset': 'reset'
    'submit': 'filter'
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
    # if !@filterAdded
    @$filter.html(@initFilter()())
      # @filterAdded = true
    @$filter.find("toggle_columns").remove()
    @$filter.prepend('<ul id = "toggle_columns" class="nav nav-pills pull-left">
      <li class="active"><a href = "#">show default</a></span>
      <li class=""><a href = "#">show all columns</a></span>
      </ul>')
    @$el.append( @grid.render().$el)
    @$el.find('table #group_header').remove()
    # @$el.find('table thead').prepend('<tr id = "group_header">
    #   <th colspan = "2"></th>
    #   <th colspan = "4">Conversion</th></tr>
    #   <th colspan = "4">ATC</th></tr>
    #   <th colspan = "4">PVR</th></tr>
    #   ')
    @$el.append( @paginator.render().$el)
    @$el.append( @paginator.render().$el)
    # @$el.append( @export_csv_button() )
    @delegateEvents()
    
    if @trigger
      @trigger = false
      @$el.find('td a.query').first().trigger('click')
    this

  unrender: =>
    @active = false
    @unrender_search_results()
    @clear_filter()
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
    @active = true
    @$el.find('.ajax-loader').css('display', 'block')
    if data and data.query
      @collection.query = data.query
    else
      @collection.query = null
    @collection.get_items()
    @trigger = true

  
  unrender_search_results: =>
    @$el.children().not('.ajax-loader, #' + @$filter.attr('id')).remove()
    @$el.find('.ajax-loader').hide()
  


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
          stats_type: 'atc'
        )
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
    {name: 'con',
    label: 'Conversion',
    editable: false,
    cell: 'number'},
    {name: 'con_trend_score',
    label: 'Con Trend Score',
    editable: false,
    cell: 'number',
    },
    {name: 'con_ooc_score',
    label: 'Con OOC',
    editable: false,
    cell: 'number',
    },
    {name: 'con_rank_score',
    label: 'Con Rank Score',
    editable: false,
    cell: 'number',
    }
    {name: 'atc',
    label: 'ATC',
    editable: false,
    cell: 'number'},
    {name: 'pvr',
    label: 'PVR',
    editable: false,
    cell: 'number'}
    ]

    columns


  clear_filter: =>
     @$filter.children().remove()

  initFilter: =>
    _.template('<div id = "filter_row" class="input-prepend input-append filter-box"><button class="btn btn-primary filter">Filter</button><form><input type="text" placeholder="Type to filter results"/></form><button class="btn btn-primary reset">Reset</button></div>')
  
  filter: (e) =>
    e.preventDefault()
    query = @$el.find(".filter-box input[type=text]").val()
    @collection.query = query
    if query
      @collection.get_items()
      @active = true
      @trigger = true

  reset: (e) =>
    e.preventDefault()
    @router.update_path('/query_monitoring/metrics/query/')
    @$el.find(".filter-box input[type=text]").val('')
    @collection.query = null
    @active = true
    @collection.get_items()
    @trigger = true
