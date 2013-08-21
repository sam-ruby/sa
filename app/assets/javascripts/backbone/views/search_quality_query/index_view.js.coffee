Searchad.Views.SearchQualityQuery ||= {}

class Searchad.Views.SearchQualityQuery.IndexView extends Backbone.View
  initialize: (options) =>
    
    _.bindAll(this, 'render', 'initTable')
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection =
      new Searchad.Collections.SearchQualityQueryCollection()
    @initTable()

    @controller.bind('search-quality-query:index', @get_items)
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('reset', @render)
  
  active: false

  gridColumns: ->
    class QueryCell extends Backgrid.Cell
      controller: SearchQualityApp.Controller
      router: SearchQualityApp.Router

      events:
        click: 'handleQueryClick'

      handleQueryClick: (e) ->
        e.preventDefault()
        id = @model.get('id')
        data =
          id: id
          query_items: @model.get('query_items')
          top_rev_items: @model.get('top_rev_items')
        
        @controller.trigger('search:query-items:index', data)
        new_path = 'search/item_id/' + id
        @router.update_path(new_path)

      render: ->
        value = @model.get(@column.get('name'))
        formatted_value = '<a href="#">' + value + '</a>'
        @$el.html(formatted_value)
        @delegateEvents()
        return this
    
    columns = [{
    name: 'search_rev_rank_correlation',
    label: I18n.t('search_analytics.rev_rank_correlation'),
    editable: false,
    cell: 'number'},
    {name: 'query_revenue',
    label: I18n.t('search_analytics.revenue'),
    editable: false,
    cell: 'number'},
    {name: 'query_str',
    label: I18n.t('search_analytics.query_string'),
    editable: false,
    cell: QueryCell},
    {name: 'query_count',
    label: I18n.t('search_analytics.query_count'),
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

  get_items: (data) =>
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.get_items(data)

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
    this
