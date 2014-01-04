Searchad.Views.QueryMonitoring ||= {}
Searchad.Views.QueryMonitoring.Metric ||= {}

class Searchad.Views.QueryMonitoring.Metric.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection = new Searchad.Collections.QueryMonitoringMetricCollection()
    @$filter = @$el.find('#qm-filter')
    @$result = @$el.find('#qm-table-content')
    @$ajax_loader = @$el.find('.ajax-loader')
    @init_table()
    @controller.bind('date-changed', =>
      @get_items(trigger: true) if @active)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('reset', => @render())
    @collection.bind('request', =>
      @clean_search_results()
      @$ajax_loader.show()
      @controller.trigger('qm:sub-content:cleanup')
    )
    Utils.InitExportCsv(this, "/monitoring/metrics/get_metric_monitor_table_data.csv")
    @undelegateEvents()
    @active = false
    @is_shown_all_columns = false
    @trigger = false

  events: =>
    'click a.filter': 'filter'
    'click a.reset': 'reset'
    'submit': 'filter'
    'click #show-default-columns':'show_default_columns'
    'click #show-all-columns':'show_all_columns'
    'click .export-csv a': (e) ->
      e? e.preventDefault()
      console.log("clickcsv")
      date = @controller.get_filter_params().date
      fileName = "query_metrics_monitoring_#{date}.csv"
      data =
        date: date
      console.log("data", data);
      # data['query'] = @collection.query if @collection.query
      @export_csv($(e.target), fileName, data)

  render: =>
    return unless @active
    @$ajax_loader.hide()
    if @collection.size() == 0
      return @render_error(@collection.data.query) 
    # add filter
    filter_template = JST['backbone/templates/query_monitoring/metrics/filter']
    @$filter.html(filter_template(@collection.data))
    # render grid
    @$result.html(@grid.render().$el)
    @$result.find('.group-header-rows').remove()
    # append group-header
    @$result.find('table thead').prepend(JST['backbone/templates/query_monitoring/metrics/table_group_header']())
    if @is_shown_all_columns
      @show_all_columns()
    else
      @show_default_columns()
    # add paginator
    @$result.append( @paginator.render().$el)
    @$result.append( @export_csv_button())
    # when resetting the form, automaticlly choose the first item
    @$result.find('td a.query').first().click()
    @delegateEvents() 
    # this

  render_error: (query) ->
    @$result.html(JST['backbone/templates/shared/no_data']({query:query}))

  unrender: =>
    @active = false
    @clean_search_results()
    @$filter.empty()
    @undelegateEvents()


  clean_search_results: =>
    @$result.empty()
    @$ajax_loader.hide()


  init_table: () =>
    @grid = new Backgrid.Grid(
      columns: @grid_columns()
      collection: @collection
    )   
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )


  get_items: (data) =>
    @active = true
    @trigger = true
    # if there is already collection, with the same date and no query param, then directly render
    # optional, if don't detect if it is one. it won't refresh to page 1 every render
    if @collection.data.date == @controller.get_filter_params().date &&
    @collection.data.query == null &&
    @collection.state.currentPage ==1 
      @render()
      return
    # if needs to fetch data, process first
    if data and data.query
      @collection.data.query = data.query
    else
      @collection.data.query = null
    @collection.data.date = @controller.get_filter_params().date
    # get_first_page, backgrid function
    @collection.getPage(1)


  show_all_columns:(e) =>
    @$el.find('li').removeClass('active')
    @$el.find('li#show-all-columns').addClass('active')
    @$el.find('table').addClass('all-columns-with-group-header')
    @$el.find('table').removeClass('default-columns-with-group-header')
    @$el.find('tr#qm-group-head-all-cols').show()
    @$el.find('tr#qm-group-head-default-cols').hide()
    @is_shown_all_columns = true


  show_default_columns:(e)=>
    @$el.find('li').removeClass('active')
    @$el.find('li#show-default-columns').addClass('active')
    # hide unnessasary column
    @$el.find('table').addClass('default-columns-with-group-header')
    @$el.find('table').removeClass('all-columns-with-group-header')
    @$el.find('tr#qm-group-head-all-cols').hide()
    @$el.find('tr#qm-group-head-default-cols').show()
    @is_shown_all_columns = false

  
  filter: (e) =>
    e.preventDefault()
    query = @$el.find("input#filter-text").val()
    @collection.data.query = query
    if query
      @collection.getPage(1)
      @active = true
      @trigger = true


  reset: (e) =>
    e.preventDefault()
    @router.update_path('/query_monitoring/metrics/query/')
    @$el.find("input#filter-text").val('')
    @collection.data.query = null
    @active = true
    @collection.getPage(1)
    @trigger = true


  grid_columns:  ->
    that = this
    # Backgrid CADQueryCell is defined in util/backgrid.customize.js
    class QueryCell extends Backgrid.CADQueryCell
      handleQueryClick: (e) =>
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = $(e.target).text()
        that.controller.trigger('qm:sub-content',
          query: query
          tab: "metrics"
          view: 'daily')
        new_path = 'query_monitoring/metrics/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)

    helpInfo = {
      trend: "Trend score for that metric on selected date. The higher the trend score is, 
        the worse downwarding the trend of the metric is. 
        If the trend score is 0, it indicates that query has no downward trending",
      ooc: "Out of Control score for that metric on selected date. The higher the ooc score is, 
        the more out of control the metric is (compare with predicted value) 
        If the trend score is 0, it indicates that query has is in control",
      rank_score: "Rank score is considering count, trend score and ooc score for the metric on the selected date. 
        Larger query count, high out of control, and severe downward trending would cause high rank_score.
        The formula is sqrt(query_count) * (ooc_score + trend_score)
      "
    }
 
    columns = [{
    name: 'query',
    label: I18n.t('query'),
    editable: false,
    cell: QueryCell},
    {name: 'count',
    label: 'Query Count',
    editable: false,
    cell: 'integer',
    headerCell: 'helper'},
    {name: 'con',
    label: 'Conversion(%)',
    editable: false,
    cell: 'number'},
    {name: 'con_rank_score',
    label: 'Rank Score',
    editable: false,
    cell: 'number',
    helpInfo: helpInfo.rank_score
    headerCell:'helper'
    },
    {name: 'con_ooc_score',
    label: 'OOC',
    editable: false,
    cell: 'number',
    helpInfo: helpInfo.ooc,
    headerCell:'helper'
    },
    {name: 'con_trend_score',
    label: 'Trend',
    editable: false,
    cell: 'number',
    helpInfo: helpInfo.trend,
    headerCell:'helper'
    },
    {name: 'pvr',
    label: 'PVR(%)',
    editable: false,
    cell: 'number'},
    {name: 'pvr_rank_score',
    label: 'Rank Score',
    editable: false,
    cell: 'number'},
    {name: 'pvr_ooc_score',
    label: 'OOC',
    editable: false,
    cell: 'number'},
    {name: 'pvr_trend_score',
    label: 'Trend',
    editable: false,
    cell: 'number'},
    {name: 'atc',
    label: 'ATC(%)',
    editable: false,
    cell: 'number'},
    {name: 'atc_rank_score',
    label: 'Rank Score',
    editable: false,
    cell: 'number'},
    {name: 'atc_ooc_score',
    label: 'OOC',
    editable: false,
    cell: 'number'},
    {name: 'atc_trend_score',
    label: 'Trend',
    editable: false,
    cell: 'number'}
    ]
    return columns
