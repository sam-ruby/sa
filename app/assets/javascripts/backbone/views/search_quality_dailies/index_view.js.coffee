Searchad.Views.SearchQualityDailies ||= {}

class Searchad.Views.SearchQualityDailies.IndexView extends Backbone.View
  initialize: (options) =>
    
    _.bindAll(this, 'render', 'initTable')
    @controller = options.controller
    @router = options.router
    @collection = new Searchad.Collections.SearchQualityDailiesCollection()
    @initTable()

    @controller.bind('search_quality_dailies:index',
      @collection.get_items)
    @controller.bind('date_changed', @collection.get_items)

    @collection.bind('reset', @render)

  template: JST["backbone/templates/search_quality_dailies/list"]
  
  el: $('#search_quality_queries')

  active: false

  addAll: () =>
    @options.searchQualityDailies.each(@addOne)

  addOne: (searchQualityDaily) =>
    view = new Searchad.Views.SearchQualityDailies.SearchQualityDailyView({model : searchQualityDaily})
    @$("tbody").append(view.render().el)

  gridColumns: (ref) ->
    class QueryCell extends Backgrid.Cell
      viewRef: ref

      events:
        click: 'handleQueryClick'

      handleQueryClick: (e) =>
        e.preventDefault()
        id = @model.get('id')
        data =
          id: id
          query_items: @model.get('query_items')
          top_rev_items: @model.get('top_rev_items')
        
        @viewRef.controller.trigger('query_items:index', data)
        currentPath = window.location.hash.replace('#', '')
        newPath = Utils.UpdateURLParam(currentPath, 'query_items', 'get_items')
        newPath = Utils.UpdateURLParam(newPath, 'item_id', id)
        @viewRef.router.navigate(newPath)

      render: ->
        value = @model.get(@column.get('name'))
        id = @model.get('id')
        formatted_value = '<a href="#">' + value + '</a>'
        $(@$el).html(formatted_value)
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
      columns: @gridColumns(this)
      collection: @collection
    )
    
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )

  unrender: =>
    @active = false

  render: =>
    @active = true
    $(@el).children().remove()
    $(@el).append( @grid.render().$el)
    $(@el).append( @paginator.render().$el)
    return this
