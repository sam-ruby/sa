Searchad.Views.AdhocQuery ||= {}

class Searchad.Views.AdhocQuery.SimpleSearchView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @$search_results = $(options.el_results)
    @controller.bind('date-changed', => @do_search() if @active)
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('adhoc_query:search_content_clean_up', @unrender)
    @queryStatsCollection =
      new Searchad.Collections.QueryStatsDailyCollection()
    @initTable()
    @active = false
    @trigger = false

    @queryStatsCollection.bind('reset', @render_s_results)
    @queryStatsCollection.bind('request', =>
      @search_results_cleanup()
      @$search_results.find('.ajax-loader').css('display', 'block')
      @controller.trigger('sub-content-cleanup')
      @controller.trigger('search:sub-tab-cleanup')
    )
    Utils.InitExportCsv(this, "/search/get_query_stats_date.csv")
    @undelegateEvents()

  events: =>
    'click .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      if @query
        query = @query.replace(/\s+/g, '_')
        query = query.replace(/"|'/, '')
        fileName = "search_#{query}_#{date}.csv"
        data =
          date: date
          query: @query
      else
        data =
          date: date
        fileName = "search_#{date}.csv"
      @export_csv($(e.target), fileName, data)

  do_search: (data) =>
    @active = true
    @search_results_cleanup()
    data || = { }
    if data.query
      @query = data.query
    else
      data.query = @query
    @queryStatsCollection.query = @query
    @queryStatsCollection.get_items()
    @trigger = true

  unrender: =>
    @active = false
    @search_results_cleanup()
    @$el.find('.ajax-loader').hide()
    @undelegateEvents()

  render_error: ->
    @$search_results.append($('<span>').addClass(
      'label label-important').append("No data available for #{@query}"))
  
  search_results_cleanup: =>
    @$search_results.children().not('.ajax-loader').remove()

  initTable: =>
    columns =  @grid_columns()
    @grid = new Backgrid.Grid(
      columns: columns
      collection: @queryStatsCollection
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @queryStatsCollection
    )
  
  render_s_results: =>
    return unless @active
    @$search_results.find('.ajax-loader').hide()
    return @render_error() if @queryStatsCollection.length == 0
    
    @$search_results.append($('<div>').css('text-align', 'left').css(
      'margin-bottom': '1em').append(
      $('<i>').addClass('icon-search').css(
        'font-size', 'large').append(
        '&nbsp; Results for : ' + @query)))
    @$search_results.append(@grid.render().$el)
    @$search_results.append(@paginator.render().$el)
    @$search_results.append(@export_csv_button())
    
    if @trigger
      @trigger = false
      @$search_results.find('td a.query').first().trigger('click')
    this

  grid_columns: =>
    that = this
    class SearchQueryCell extends Backgrid.CADQueryCell
      handleQueryClick: (e) =>
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = $(e.target).text()
        @controller.trigger('search:sub-content',
          query: query
          view: 'daily')
        new_path = 'adhoc_query/mode/search/query/' +
          encodeURIComponent(query)
        that.router.update_path(new_path)

    class DateFormatter
      fromRaw: (rawValue) ->
        return 0 unless rawValue
        date_obj = new Date(rawValue)
        date_obj.toString('MMM dd, yyyy')
      
    columns = [
      {name: 'data_date',
      label: 'Date',
      editable: false,
      formatter: DateFormatter,
      cell: 'date'},
      {name: 'query',
      label: I18n.t('search_analytics.query_string'),
      editable: false,
      cell: SearchQueryCell},
      {name: 'cat_rate',
      label: I18n.t('dashboard.catalog_overlap'),
      editable: false,
      cell: 'number',
      formatter: Utils.PercentFormatter},
      {name: 'show_rate',
      label: I18n.t('dashboard.results_shown_in_search'),
      editable: false,
      cell: 'number',
      formatter: Utils.PercentFormatter},
      {name: 'rel_score',
      label: I18n.t('dashboard.overall_relevance_score'),
      editable: false,
      cell: 'number'},
      {name: 'rel_conv_score',
      label: I18n.t('search_analytics.rev_rank_correlation'),
      editable: false,
      cell: 'number'},
      {name: 'query_revenue',
      label: I18n.t('search_analytics.revenue'),
      editable: false,
      cell: 'number',
      formatter: Utils.CurrencyFormatter},
      {name: 'query_count',
      label: I18n.t('search_analytics.query_count'),
      editable: false,
      cell: 'integer'},
      {name: 'query_con',
      label: 'Conversion',
      editable: false,
      cell: 'number'
      formatter: Utils.PercentFormatter}
    ]
    return columns
