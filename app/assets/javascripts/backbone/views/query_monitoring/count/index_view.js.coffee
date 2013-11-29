Searchad.Views.QueryMonitoring ||= {}
Searchad.Views.QueryMonitoring.Count ||= {}

class Searchad.Views.QueryMonitoring.Count.IndexView extends Backbone.View
  initialize: (options) =>
    @trigger = false
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection = new Searchad.Collections.QueryMonitoringCountCollection()
    @$filter = @$el.find(options.el_filter)
    @initTable()

    @$el.find('.ajax-loader').hide()
    
    @controller.bind('date-changed', =>
      @get_items(trigger: true) if @active)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('reset', @render)
    @collection.bind('request', =>
      @$el.find('.ajax-loader').css('display', 'block')
      @controller.trigger('qm-count:sub-content-cleanup')
    )
    Utils.InitExportCsv(this, "/monitoring/count/get_words.csv")
    @undelegateEvents()
    @active = false

  events: =>
    'click .filter': 'filter'
    'click .reset': 'reset'
    'submit': 'filter'
    'click .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      fileName = "query_count_monitoring_#{date}.csv"
      data =
        date: date
      data['query'] = @collection.query if @collection.query
      @export_csv($(e.target), fileName, data)
  
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
        that.controller.trigger('qm-count:sub-content',
          query: query
          view: 'daily')
        new_path = 'query_monitoring/count/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)

      render: ->
        value = @model.get(@column.get('name'))
        formatted_value = '<a class="query" href="#">' + value + '</a>'
        @$el.html(formatted_value)
        @delegateEvents()
        return this
    
    columns = [{
    name: 'query_str',
    label: I18n.t('query'),
    editable: false,
    cell: QueryCell},
    {name: 'query_score',
    label: 'Query Score',
    editable: false,
    cell: 'integer',
    headerCell: 'custom'},
    {name: 'query_count',
    label: I18n.t('search_analytics.queries'),
    editable: false,
    cell: 'integer'},
    {name: 'query_con',
    label: I18n.t('perf_monitor.conversion_rate'),
    editable: false,
    cell: 'number',
    formatter: Utils.PercentFormatter},
    {name: 'query_con',
    label: I18n.t('perf_monitor.add_to_cart_rate'),
    editable: false,
    cell: 'number',
    formatter: Utils.PercentFormatter}]

    columns
  
  initFilter: =>
    _.template('<div class="input-prepend input-append filter-box"><button class="btn btn-primary filter">Filter</button><form><input type="text" placeholder="Type to filter results"/></form><button class="btn btn-primary reset">Reset</button></div>')
  
  initTable: () =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )
  
  filter: (e) =>
    e.preventDefault()
    query = @$el.find(".filter-box input[type=text]").val()
    @collection.query = query
    @collection.get_items() if query
    @trigger = true

  reset: (e) =>
    e.preventDefault()
    @router.update_path('/search_rel')
    @$el.find(".filter-box input[type=text]").val('')
    @collection.query = null
    @collection.get_items()
    @trigger = true

  get_items: (data) =>
    @$el.find('.ajax-loader').css('display', 'block')
    if data and data.query
      @collection.query = data.query
    else
      @collection.query = null
    @collection.get_items()
    @trigger = true

  clear_filter: =>
    @$filter.children().remove()
  
  unrender_search_results: =>
    @$el.children().not('.ajax-loader, #' + @$filter.attr('id')).remove()
    @$el.find('.ajax-loader').hide()
  
  unrender: =>
    @active = false
    @unrender_search_results()
    @clear_filter()
    @undelegateEvents()
    this

  render_error: (query) ->
    @controller.trigger('qm-count:sub-tab-cleanup')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )
  
  render: =>
    @unrender_search_results()
    return @render_error(@collection.query) if @collection.size() == 0
    unless @active
      @$filter.append(@initFilter()())
    
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @export_csv_button() )
    @delegateEvents()
    
    if @trigger
      @trigger = false
      @$el.find('td a.query').first().trigger('click')
    @active = true
    this
