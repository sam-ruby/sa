Searchad.Views.SearchQualityQuery ||= {}

class Searchad.Views.SearchQualityQuery.IndexView extends Backbone.View
  initialize: (options) =>
    @trigger = false
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection =
      new Searchad.Collections.SearchQualityQueryCollection()
    @$filter = @$el.find(options.el_filter)
    @initTable()
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('content-cleanup', @clear_filter)

    @collection.bind('reset', @render)
    @collection.bind('request', =>
      @unrender_search_results()
      @$el.find('.ajax-loader').css('display', 'block')
      @controller.trigger('sub-content-cleanup')
      @controller.trigger('search:sub-tab-cleanup')
    )
    
    Utils.InitExportCsv(this, "/search_rel/get_search_words.csv")
    @undelegateEvents()
    @active = false
        
  events:
    'click .filter': 'filter'
    'click .reset': 'reset'
    'submit': 'filter'
    'click .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      fileName = "query_analysis_#{date}.csv"
      data =
        date: date
      data['query'] = @collection.query if @collection.query
      @export_csv($(e.target), fileName, data)
  
  filter: (e) =>
    e.preventDefault()
    query = @$el.find("input#filter-text").val()
    @collection.query = query
    if query
      @collection.get_items()
      @active = true
    @trigger = true

  reset: (e) =>
    e.preventDefault()
    @router.update_path('/search_rel')
    @$el.find("input#filter-text").val('')
    @collection.query = null
    @collection.get_items()
    @active = true
    @trigger = true

  unrender_search_results: =>
    @$el.children().not('.ajax-loader, #' + @$filter.attr('id')).remove()
    @$el.find('.ajax-loader').hide()
  
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
    if data and data.query
      @collection.query = data.query
    else
      @collection.query = null
    @collection.get_items()
    @trigger = true

  clear_filter: =>
    @$filter.children().remove()

  unrender: =>
    @active = false
    @unrender_search_results()
    @clear_filter()
    @undelegateEvents()
    this

  render_error: (query) ->
    @$el.append(JST['backbone/templates/shared/no_data']({query:query}))
  
  render: =>
    return unless @active
    @unrender_search_results()
    return @render_error(@collection.query) if @collection.size() == 0
    @$filter.html(JST['backbone/templates/shared/general_filter']({query:@collection.query}))
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @export_csv_button() )
    @delegateEvents()
    
    if @trigger
      @trigger = false
      @$el.find('td a.query').first().trigger('click')
    this
   

  gridColumns: ->
    that = this
    class QueryCell extends Backgrid.CADQueryCell
      handleQueryClick: (e) ->
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = @model.get('query_str')
        that.controller.trigger('search:sub-content',
          query: query
          view: 'daily'
          # tab: Searchad.UserLatest.sub_tabs.current_tab
        )
        new_path = 'search_rel/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)
        false
    
    columns = [{
    name: 'query_str',
    label: I18n.t('search_analytics.query_string'),
    editable: false,
    cell: QueryCell},
    {name: 'query_count',
    label: I18n.t('search_analytics.query_count'),
    editable: false,
    cell: 'integer'},
    {name: 'rank_metric',
    label: "Rank Metric",
    editable: false,
    cell: 'number',
    headerCell: "helper"},
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
    {name: 'query_con',
    label: 'Conversion',
    editable: false,
    cell: 'number'
    formatter: Utils.PercentFormatter}]

    columns
