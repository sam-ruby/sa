Searchad.Views.Search ||= {}

class Searchad.Views.Search.IndexView extends Backbone.View
  initialize: (options) ->
    @trigger = false
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    
    # @$search_form = $(options.el_form)
    @$search_results = $(options.el_results)

    @controller.bind('content-cleanup', @unrender)
    # @controller.bind('sub-content-cleanup', @search_results_cleanup)
    @queryStatsCollection =
      new Searchad.Collections.QueryStatsDailyCollection()
    @initTable()
    
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
    'submit': 'do_search'
    'click button.search-btn': 'do_search'
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

  # search_form_template: JST['backbone/templates/search/form']

  # load_search_results: (query) =>
  #   @$search_form.find('input.search-query').val(query)
  #   @$search_form.find('button.search-btn').first().trigger('click')
  
  do_search: (data) =>
    # console.log("do_search", data);
    # e.preventDefault()
    @active = true
    @search_results_cleanup()
    @query = data.query
    # @query = @$search_form.find('input.search-query').val()
    
    @queryStatsCollection.query = @query
    @queryStatsCollection.get_items()
    @trigger = true

  unrender: =>
    @active = false
    # @$search_form.children().remove()
    @search_results_cleanup()
    @$el.find('.ajax-loader').hide()
    @undelegateEvents()

  render_error: ->
    @$search_results.append($('<span>').addClass(
      'label label-important').append("No data available for #{@query}"))
  
  # render: =>
  #   # @$search_form.append(@search_form_template())
  #   @delegateEvents()

  search_results_cleanup: =>
    @$search_results.children().not('.ajax-loader').remove()

  initTable: =>
    that = this
    class SearchQueryCell extends Backgrid.Cell
      events:
        'click': 'handleQueryClick'

      handleQueryClick: (e) =>
        e.preventDefault()
        $(e.target).parents('table').find('tr.selected').removeClass(
          'selected')
        $(e.target).parents('tr').addClass('selected')
        query = $(e.target).text()
        that.controller.trigger('search:sub-content',
          query: query
          view: 'daily')
        new_path = 'search/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)
      
      render: =>
        value = @model.get(@column.get('name'))
        formatted_value = '<a class="query" href="#">' + value + '</a>'
        @$el.html(formatted_value)
        @delegateEvents()
        return this

    @grid = new Backgrid.Grid(
      columns: [{
        name: 'query',
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
        {name: 'search_rev_rank_correlation',
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
        formatter: Utils.PercentFormatter}]
      collection: @queryStatsCollection)

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
