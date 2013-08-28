Searchad.Views.PoorPerforming ||= {}

class Searchad.Views.PoorPerforming.IndexView extends Backbone.View
  initialize: (options) =>
    
    _.bindAll(this, 'render', 'initTable')
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection = new Searchad.Collections.PoorPerformingCollection()
    @initTable()

    @$el.find('.ajax-loader').hide()
    
    @controller.bind('poor-performing:index', @get_items)
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('reset', @render)
  
  active: false

  gridColumns:  ->
    class QueryCell extends Backgrid.Cell
      controller: SearchQualityApp.Controller
      router: SearchQualityApp.Router

      events:
        'click': 'handleQueryClick'

      handleQueryClick: (e) =>
        e.preventDefault()
        $(e.target).parents('table').find('tr.selected').removeClass('selected')
        $(e.target).parents('tr').addClass('selected')
        id = @model.get('id')
        @controller.trigger('pp:stats', query: @model.get('query'))
        new_path = 'poor_performing/stats/query/' + @model.get('query')
        @router.update_path(new_path)

      render: ->
        value = @model.get(@column.get('name'))
        formatted_value = '<a href="#">' + value + '</a>'
        @$el.html(formatted_value)
        @delegateEvents()
        return this
    
    columns = [{
    name: 'query',
    label: I18n.t('query'),
    editable: false,
    cell: QueryCell},
    {name: 'query_revenue',
    label: I18n.t('search_analytics.revenue'),
    editable: false,
    cell: 'number'},
    {name: 'query_count',
    label: I18n.t('search_analytics.queries'),
    editable: false,
    cell: 'number'},
    {name: 'query_con',
    label: I18n.t('perf_monitor.conversion_rate'),
    editable: false,
    cell: 'number'},
    {name: 'query_atc',
    label: I18n.t('perf_monitor.add_to_cart_rate'),
    editable: false,
    cell: 'number'},
    {name: 'query_pvr',
    label: I18n.t('perf_monitor.product_view_rate'),
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
    return this
