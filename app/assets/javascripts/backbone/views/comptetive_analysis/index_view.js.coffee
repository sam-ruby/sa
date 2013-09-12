Searchad.Views.CompAnalysis ||= {}

class Searchad.Views.CompAnalysis.IndexView extends Backbone.View
  initialize: (options) =>
    
    _.bindAll(this, 'render', 'initTable')
    @trigger = false
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
        el: '#ca-subtabs-content')
    amazonItemsView.listenTo(
      @controller, 'ca:amazon-items:index', amazonItemsView.get_items)
    amazonItemsView.listenTo(
      @controller, 'ca:content-cleanup', amazonItemsView.unrender)

  active: false

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
  
  initTable: () =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )

  make_tab_active: =>

  get_items: (data) =>
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.get_items(data)
    if data and data.query
      @controller.trigger('ca:amazon-items:index', data)
    else
      @trigger = true

  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()

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
