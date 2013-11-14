Searchad.Views.SearchQualityQuery ||= {}

class Searchad.Views.SearchQualityQuery.IndexView extends Backbone.View
  initialize: (options) =>
    
    _.bindAll(this, 'render', 'initTable')
    @trigger = false
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection =
      new Searchad.Collections.SearchQualityQueryCollection()
    @initTable()

    @controller.bind('date-changed', =>
      @get_items() if @active)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('reset', @render)
        
  active: false

  gridColumns: ->
    that = this
    class QueryCell extends Backgrid.Cell
      controller: SearchQualityApp.Controller
      router: SearchQualityApp.Router
      events:
        click: 'handleQueryClick'

      handleQueryClick: (e) ->
        e.preventDefault()
        $(e.target).parents('table').find('tr.selected').removeClass(
          'selected')
        $(e.target).parents('tr').addClass('selected')
        query = @model.get('query_str')
        that.controller.trigger('search:sub-content',
          query: query
          view: 'daily'
          tab: 'rel-rev-analysis')
        new_path = 'search_rel/query/' + query
        that.router.update_path(new_path)
        false

      render: ->
        value = @model.get(@column.get('name'))
        formatted_value = '<a class="query" href="#">' + value + '</a>'
        @$el.html(formatted_value)
        @delegateEvents()
        return this
    
    columns = [{
    name: 'query_str',
    label: I18n.t('search_analytics.query_string'),
    editable: false,
    cell: QueryCell},
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

    columns
  
  initTable: () =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )

  get_items: (data) =>
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.get_items(data)
    if data and data.query
      @controller.trigger('search:rel-rev', data)
    else
      @trigger = true

  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
    this

  render: =>
    @active = true
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    if @trigger
      @trigger = false
      @$el.find('td a.query').first().trigger('click')
    this
