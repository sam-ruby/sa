Searchad.Views.CompAnalysis ||= {}

class Searchad.Views.CompAnalysis.IndexView extends Backbone.View
  initialize: (options) =>
    
    @trigger = false
    @fuzzy_search = false
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection = new Searchad.Collections.CompAnalysisCollection()
    @initTable()

    @$el.find('.ajax-loader').hide()
    
    @controller.bind('year-week-changed', =>
      @get_items() if @active)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('reset', @render)
    
    subtabsView =
      new Searchad.Views.CompAnalysis.SubTabs.IndexView(
        el: '#ca-subtabs'
      )
    
    walmartItemsView =
      new Searchad.Views.PoorPerforming.WalmartItems.IndexView(
        el: '#ca-subtabs-content'
        view: 'weekly')
    walmartItemsView.listenTo(
      @controller, 'ca:walmart-items:index', walmartItemsView.get_items)
    walmartItemsView.listenTo(
      @controller, 'ca:content-cleanup', walmartItemsView.unrender)
   
    amazonItemsView =
      new Searchad.Views.PoorPerforming.AmazonItems.IndexView(
        el: '#ca-subtabs-content'
        top_32_tab: '#ca-amazon-top-subtabs'
        view: 'weekly')
    amazonItemsView.listenTo(
      @controller, 'ca:amazon-items:index', amazonItemsView.get_items)
    amazonItemsView.listenTo(
      @controller, 'ca:content-cleanup', amazonItemsView.unrender)
    
    amazonItemsView.listenTo(
      @controller, 'ca:amazon-items:all-items',
      amazonItemsView.render_all_items)
    amazonItemsView.listenTo(
      @controller, 'ca:amazon-items:in-top-32',
      amazonItemsView.render_in_top_32)
    amazonItemsView.listenTo(
      @controller, 'ca:amazon-items:not-in-top-32',
      amazonItemsView.render_not_in_top_32)

    amazonItemsView.collection.on('reset', ->
      if @collection.at(0).get('all_items').length > 0
        @controller.trigger('ca:amazon-items:overlap',
          query: @query
          collection: @collection)
    , amazonItemsView)
    @controller.bind('ca:amazon-items:in-top-32', @render_in_top_32)
    @controller.bind('ca:amazon-items:not-in-top-32', @render_not_in_top_32)
    
    amazonStatsView =
      new Searchad.Views.CompAnalysis.AmazonItems.IndexView(
        el: '#ca-amazon-overlap')
    amazonStatsView.listenTo(
      @controller, 'ca:amazon-items:overlap', amazonStatsView.render)
    amazonStatsView.listenTo(
      @controller, 'ca:content-cleanup', amazonStatsView.unrender)

  active: false
  events:
    'click a.query': (e) ->
      query = $(e.target).text()
      @controller.trigger('ca:amazon-items:index', query: query)
      new_path = 'comp_analysis/amazon_items/query/' +
        encodeURIComponent(query)
      @router.update_path(new_path)
    'click .filter': 'filter'
    'click .reset': 'reset'
    'submit': 'filter'

  gridColumns:  ->
    class QueryCell extends Backgrid.Cell
      controller: SearchQualityApp.Controller

      events:
        'click': 'handleQueryClick'

      handleQueryClick: (e) =>
        e.preventDefault()
        $(e.target).parents('table').find('tr.selected').removeClass('selected')
        $(e.target).parents('tr').addClass('selected')
        id = @model.get('id')
        @controller.trigger('ca:content-cleanup')

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
    {name: 'catalog_overlap',
    label: I18n.t('dashboard.catalog_overlap'),
    editable: false,
    cell: 'number'},
    {name: 'results_shown_in_search',
    label: I18n.t('dashboard.results_shown_in_search'),
    editable: false,
    cell: 'number'},
    {name: 'overall_relevance_score',
    label: I18n.t('dashboard.overall_relevance_score'),
    editable: false,
    cell: 'number'}]
    
    columns

  initFilter: =>
     _.template('<div class="input-prepend input-append filter-box pull-right"><button class="btn btn-primary filter">Filter</button><form><input type="text" placeholder="Type a query word"/></form><button class="btn btn-primary reset">Reset</button></div>')
  
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
    @get_items(query: query, saveQuery: true) if query

  reset: =>
    @$el.find(".filter-box input[type=text]").val('')
    @get_items(saveQuery: false)

  get_items: (data) =>
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.fetch(data)
    if data and data.query and !data.saveQuery
      @controller.trigger('ca:amazon-items:index', data)
    else
      @trigger = true

  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()

  render: =>
    @$el.children().not('.ajax-loader, .filter-box').remove()
    @$el.find('.ajax-loader').hide()
    unless @active
      @$el.append( @initFilter()())
      @delegateEvents()
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    if @trigger
      @trigger = false
      @fuzzy_search = false
      @$el.find('td a.query').first().trigger('click')
    @active = true
    this
