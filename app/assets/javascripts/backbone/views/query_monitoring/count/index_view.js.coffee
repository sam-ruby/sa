Searchad.Views.QueryMonitoring ||= {}
Searchad.Views.QueryMonitoring.Count ||= {}

class Searchad.Views.QueryMonitoring.Count.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection = new Searchad.Collections.QueryMonitoringCountCollection()
    @initTable()
    @controller.bind('date-changed', =>
      @get_items(trigger: true) if @active)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('reset', @render)
    @collection.bind('request', @prepare_for_render)

    Utils.InitExportCsv(this, "/monitoring/count/get_words.csv")
    @undelegateEvents()
    @$filter = @$el.find('#qm-filter')
    @$result = @$el.find('#qm-table-content')
    @$ajax_loader = @$el.find('.ajax-loader')
    @active = false
    @trigger = false

  events: =>
    'click a.filter': 'filter'
    'click a.reset': 'reset'
    'submit': 'filter'
    'click .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      fileName = "query_count_monitoring_#{date}.csv"
      data =
        date: date
      data['query'] = @collection.query if @collection.query
      @export_csv($(e.target), fileName, data)

  prepare_for_render: =>
    @$el.find('.ajax-loader').css('display', 'block')
    @controller.trigger('sub-content-cleanup')
    @controller.trigger('qm:sub-content:cleanup')
  
  initTable: () =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
      emptyText: 'No Data'
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )
  
  filter: (e) =>
    e.preventDefault()
    query = @$filter.find("#filter-text").val()
    @collection.data.query = query
    if query
      @collection.get_items()
      @active = true
      @trigger = true

  reset: (e) =>
    e.preventDefault()
    @router.update_path('/query_monitoring/count')
    @$filter.find(".filter-box input[type=text]").val('')
    @collection.data.query = null
    @active = true
    @collection.get_items()
    @trigger = true

  get_items: (data) =>
    @active = true
    @trigger = true
    # if there is already collection, with the same date and no query param,
    # then directly render
    if @collection.data.date ==@controller.get_filter_params().date && @collection.data.query ==null
        @render()
        return
    # if needs to fetch data, process first
    if data and data.query
      @collection.data.query = data.query
    else
      @collection.data.query = null
    @collection.data.date = @controller.get_filter_params().date
    @collection.get_items()
  
  unrender_search_results: =>
    @$ajax_loader.hide()
  
  unrender: =>
    @active = false
    @unrender_search_results()
    @$filter.empty()
    @$result.empty()
    @undelegateEvents()

  render: =>
    return unless @active
    @unrender_search_results()
    @$filter.html(
      JST['backbone/templates/shared/general_filter'](@collection.data))
    
    if @collection.size() == 0
      @$result.prepend(@grid.render().$el)
      return
    else
      @$result.prepend(@paginator.render().$el)
      @$result.prepend(@grid.render().$el)
    
    @$result.append( @export_csv_button() ) unless @$result.find(
      '.export-csv').length > 0
    @$result.find('td a.query').first().trigger('click')
    @delegateEvents()
    this

  gridColumns:  ->
    that = this
    class QueryCell extends Backgrid.CADQueryCell
      handleQueryClick: (e) =>
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = $(e.target).text()
        that.controller.trigger('qm:sub-content',
          query: query
          tab: "count"
          view: 'daily')
        new_path = 'query_monitoring/count/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)
    
    columns = [{
    name: 'query_str',
    label: I18n.t('query'),
    editable: false,
    cell: QueryCell},
    {name: 'query_score',
    label: 'Query Score',
    editable: false,
    cell: 'integer',
    headerCell: 'helper'},
    {name: 'query_count',
    label: I18n.t('search_analytics.queries'),
    editable: false,
    cell: 'integer'},
    {name: 'query_con',
    label: I18n.t('perf_monitor.conversion_rate'),
    editable: false,
    cell: 'number',
    formatter: Utils.PercentFormatter}]

    columns
