Searchad.Views.Search ||= {}
Searchad.Views.Search.RelRev ||= {}

class Searchad.Views.Search.RelRev.IndexView extends Backbone.View
  initialize: (options) =>
    
    _.bindAll(this, 'render', 'initTable')
    @controller = SearchQualityApp.Controller
    @collection = new Searchad.Collections.QueryItemsCollection()
    @initTable()
    
    @controller.bind('date-changed', =>
      @unrender() if @active)
    @controller.bind('sub-content-cleanup', @unrender)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('reset', @render)

  active: false

  gridColumns: =>
    class ItemCell extends Backgrid.Cell
      item_template: JST["backbone/templates/search_quality_query/query_items/item"]
      render: =>
        item = @model.get(@column.get('name'))
        formatted_value = @item_template(item)
        $(@$el).html(formatted_value)
        return this
    
    columns = [{
    name: 'walmart_item',
    label: 'Relevance Order',
    editable: false,
    cell: ItemCell},
    {name: 'rev_based_item',
    label: 'Best Seller Order',
    editable: false,
    cell: ItemCell}]

    columns

  initTable: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection)
  
  get_items: (data) =>
    @query = data.query if data.query
    @controller.trigger('search:sub-content:show-spin')
    @collection.get_items(data)

  render_error: (query) ->
    @controller.trigger('search:sub-content:hide-spin')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )
  
  render: =>
    return @render_error(@query) if @collection.size() == 0
    @active = true
    @controller.trigger('search:sub-content:hide-spin')
    @$el.children().remove()
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    this
  
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
    this
