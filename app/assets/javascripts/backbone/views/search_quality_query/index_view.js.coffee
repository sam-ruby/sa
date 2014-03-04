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
    @collection.bind('request', @prepare_for_render)

    @advanced_search_on
    Utils.InitExportCsv(this, "/search_rel/get_search_words.csv")
    @undelegateEvents()
    @active = false
        
  events:
    'click .filter': 'filter'
    'click .reset': 'reset'
    'submit': 'filter'
    'click #simple_checkbox':'show_advanced'
    'click #advanced_checkbox':'show_simple'
    'click #advanced-search-submit':'advanced_search'
    'click .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      fileName = "query_analysis_#{date}.csv"
      data =
        date: date
      data['query'] = @collection.data.query if @collection.data.query
      @export_csv($(e.target), fileName, data)
  
  filter: (e) =>
    e.preventDefault()
    query = @$el.find("input#filter-text").val()
    query = 'EXACT_WORD=' + query + 'ALL_WORD=ANY_WORD=NONE_WORD='

    @collection.data.query = query
    @collection.get_items()
    @active = true
    @trigger = true

  show_simple:=>
    @$filter.find(".row.simple").show()
    @$filter.find(".row.advanced").hide()
    $('#simple_checkbox').removeAttr("checked")
    @advanced_search_on =false

  show_advanced:=>
    $('#simple_checkbox').attr('checked')
    @$filter.find(".row.advanced").show()
    @$filter.find(".row.simple").hide()
    @advanced_search_on =true

  advanced_search:(e) =>
    e.preventDefault()
    exact_words = @$el.find("#input-exact-words").val()
    all_words = @$el.find("#input-all-words").val()
    any_words= @$el.find("#input-any-words").val()
    none_words = @$el.find("#input-none-words").val()
    @collection.data.query = 'EXACT_WORD='+ exact_words +
      'ALL_WORD='+ all_words + 'ANY_WORD='+ any_words+'NONE_WORD='+ none_words
    @collection.get_items()
    @active = true
    @trigger = true

  reset: (e) =>
    e.preventDefault()
    @router.update_path('/search_rel')
    @$el.find("input#filter-text").val('')
    @collection.data.query = null
    @collection.get_items()
    @active = true
    @trigger = true

  prepare_for_render: =>
    @$el.find('.ajax-loader').css('display', 'block')
    @controller.trigger('sub-content-cleanup')
    @controller.trigger('search:sub-tab-cleanup')

  unrender_search_results: =>
    @$el.find('.ajax-loader').hide()
  
  initTable: () =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
      emptyText: 'No Data'
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )

  get_items: (data) =>
    @active = true
    @trigger = true
    # if the date don't change, don't refetch every time
    if @collection.data.query  == null && @collection.data.date == @controller.get_filter_params().date
      @render()
      return
    # refetch
    if data and data.query
      @collection.data.query = 'EXACT_WORD=' + data.query + 'ALL_WORD=ANY_WORD=NONE_WORD='
    else
      @collection.data.query = null
    @collection.data.date = @controller.get_filter_params().date
    @collection.get_items()


  clear_filter: =>
    @$filter.children().remove()

  unrender: =>
    @active = false
    @unrender_search_results()
    @clear_filter()
    @$el.children().not('.ajax-loader').not(@$filter).remove()
    @undelegateEvents()
    this

  render: =>
    return unless @active
    @unrender_search_results()
    @$filter.html(JST['backbone/templates/shared/advanced_search']())

    if @collection.data.query
      results = @collection.data.query.match(
        /^EXACT_WORD=(.*)ALL_WORD=(.*)ANY_WORD=(.*)NONE_WORD=(.*)$/)
      @$filter.find('input#filter-text').val(results[1])
      @$filter.find('#input-exact-words').val(results[1])
      @$filter.find('#input-all-words').val(results[2])
      @$filter.find('#input-any-words').val(results[3])
      @$filter.find('#input-none-words').val(results[4])
    if @advanced_search_on
      @show_advanced()
    else
      @show_simple()
      
    if @collection.size() == 0
      $(@grid.render().$el).insertAfter(@$filter)
      return
    else
      $(@paginator.render().$el).insertAfter(@$filter)
      $(@grid.render().$el).insertAfter(@$filter)
    
    @$el.append( @export_csv_button() ) unless @$el.find(
      '.export-csv').length > 0
    @$el.find('td a.query').first().trigger('click')
    @delegateEvents()
    this
   
  gridColumns: ->
    that = this
    class QueryCell extends Backgrid.CADQueryCell
      handleQueryClick: (e) ->
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = @model.get('query')
        that.controller.trigger('search:sub-content',
          query: query
          view: 'daily'
          # tab: Searchad.UserLatest.sub_tabs.current_tab
        )
        new_path = 'search_rel/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)
        false
    
    columns = [{
    name: 'query',
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
    cell: 'integer',
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
    {name: 'search_con_rank_correlation',
    label: 'Con Rank Correlation',
    editable: false,
    cell: 'number'},
    {name: 'revenue',
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
