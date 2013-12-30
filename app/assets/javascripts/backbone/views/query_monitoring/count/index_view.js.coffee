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
      @unrender_search_results()
      @$el.find('.ajax-loader').css('display', 'block')
      @controller.trigger('qm:sub-content:cleanup')
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
    @collection.data.query = query
    if query
      @collection.get_items()
      @active = true
      @trigger = true

  reset: (e) =>
    e.preventDefault()
    @router.update_path('/search_rel')
    @$el.find(".filter-box input[type=text]").val('')
    @collection.data.query = null
    @active = true
    @collection.get_items()
    @trigger = true

  get_items: (data) =>
    @active = true
    @trigger = true
    # if there is already collection, with the same date and no query param, then directly render
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
    if query?
      msg = "No data available for #{query}"
    else
      msg = "No data available"
    @$el.append($('<span>').addClass('label label-important').append(msg))

  render: =>
    return unless @active
    @$el.find('.ajax-loader').hide()
    return @render_error(@collection.query) if @collection.size() == 0
    @$filter.html(JST['backbone/templates/shared/general_filter']())
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @export_csv_button() )
    @delegateEvents()
    
    if @trigger
      @trigger = false
      @$el.find('td a.query').first().trigger('click')
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
    headerCell: 'custom'},
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
