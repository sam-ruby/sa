Searchad.Views.CompAnalysis ||= {}

class Searchad.Views.CompAnalysis.IndexView extends Backbone.View
  initialize: (options) =>
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
    
  active: false
  events:
    'click .filter': 'filter'
    'click .reset': 'reset'
    'submit': 'filter'

  gridColumns: =>
    that = this
    class QueryCell extends Backgrid.Cell
      events:
        'click': 'handleQueryClick'
      
      handleQueryClick: (e) =>
        e.preventDefault()
        query = $(e.target).text()
        $(e.target).parents('table').find('tr.selected').removeClass('selected')
        $(e.target).parents('tr').addClass('selected')
        that.controller.trigger('search:sub-content',
          view: 'weekly'
          tab: 'amazon'
          query: query)
        new_path = 'comp_analysis/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)

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
    _.template('<div class="input-prepend input-append filter-box pull-right"><button class="btn btn-primary filter">Filter</button><form><input type="text" placeholder="Type to filter results"/></form><button class="btn btn-primary reset">Reset</button></div>')
  
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
    @unrender_search_results()
    query = @$el.find(".filter-box input[type=text]").val()
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.fetch(query: query) if query
    @trigger = true

  reset: =>
    e.preventDefault()
    @unrender_search_results()
    @$el.find(".filter-box input[type=text]").val('')
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.fetch()
    @trigger = true

  get_items: (data) =>
    @$el.find('.ajax-loader').css('display', 'block')
    if data and data.query
      @collection.fetch(fuzzy: false, query: data.query)
    else
      @collection.fetch()
    @trigger = true

  unrender_search_results: =>
    @$el.children().not('.ajax-loader, .filter-box').remove()

  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()

  render: =>
    @$el.find('.ajax-loader').hide()
    unless @active
      @$el.append( @initFilter()())
      @delegateEvents()
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    if @trigger
      @trigger = false
      @$el.find('td a.query').first().trigger('click')
    @active = true
    this
