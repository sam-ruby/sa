Searchad.Views.QueryMonitoring ||= {}
Searchad.Views.QueryMonitoring.Metric ||= {}

class Searchad.Views.QueryMonitoring.Metric.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection = new Searchad.Collections.QueryMonitoringMetricCollection()
    @$filter = @$el.find(options.el_filter)
    @initTable()
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
    @is_shown_all_columns = false
    @trigger = false

  events: =>
    'click .filter': 'filter'
    'click .reset': 'reset'
    'submit': 'filter'
    'click #show-default-columns':'show_default_columns'
    'click #show-all-columns':'show_all_columns'
    # 'click .export-csv a': (e) ->
    #   date = @controller.get_filter_params().date
    #   fileName = "query_count_monitoring_#{date}.csv"
    #   data =
    #     date: date
    #   data['query'] = @collection.query if @collection.query
    #   @export_csv($(e.target), fileName, data)


  show_all_columns:(e) =>
    e? e.preventDefault()
    # show group header
    @$el.find('table #qm-group-header-row').show()
    # hide unnessasary column
    @$el.find('table').removeClass('hide-atc-pvr-column')
    @$el.find('table').addClass('all-columns-with-group-header')
    # toggle li for select options
    @$el.find('li').removeClass('active')
    @$el.find('li#show-all-columns').addClass('active')
    @is_shown_all_columns = true

  show_default_columns: (e)=>
    e? e.preventDefault()
    @$el.find('table #qm-group-header-row').hide()
    @$el.find('table').addClass('hide-atc-pvr-column')
    @$el.find('table').removeClass('all-columns-with-group-header')
    # toggle li for select options
    @$el.find('li').removeClass('active')
    @$el.find('li#show-default-columns').addClass('active')
    @is_shown_all_columns = false

  render: =>
    return unless @active
    @$el.find('.ajax-loader').hide()
    return @render_error(@collection.query) if @collection.size() == 0
    # add filter
    filter_template = JST['backbone/templates/query_monitoring/metrics/filter']
    @$filter.html(filter_template())
    # render grid
    @$el.append( @grid.render().$el)
    # append group-header
    @$el.find('table #qm-group-header-row').remove()
    @$el.find('table thead').prepend('
      <tr id = "qm-group-header-row">
      <th colspan = "2"></th>
      <th colspan = "4">Conversion</th>
      <th colspan = "4">PVR</th>
      <th colspan = "4">ATC</th></tr>
      ')
    if @is_shown_all_columns
      @show_all_columns()
    else
      @show_default_columns()
    # add paginator
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

  clear_filter: =>
     @$filter.children().remove()
  
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
    label: 'Conversion(%)',
    editable: false,
    cell: 'number'},
    {name: 'con_trend_score',
    label: 'Con Trend',
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
    {name: 'pvr',
    label: 'PVR(%)',
    editable: false,
    cell: 'number'},
    {name: 'pvr_trend_score',
    label: 'Trend',
    editable: false,
    cell: 'number'},
    {name: 'pvr_ooc_score',
    label: 'OOC',
    editable: false,
    cell: 'number'},
    {name: 'pvr_rank_score',
    label: 'Rank Score',
    editable: false,
    cell: 'number'}
    {name: 'atc',
    label: 'ATC(%)',
    editable: false,
    cell: 'number'},
    {name: 'atc_trend_score',
    label: 'Trend',
    editable: false,
    cell: 'number'},
    {name: 'atc_ooc_score',
    label: 'OOC',
    editable: false,
    cell: 'number'},
    {name: 'atc_rank_score',
    label: 'Rank Score',
    editable: false,
    cell: 'number'}
    ]
    return columns
