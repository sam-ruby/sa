Searchad.Views.QueryItems ||= {}

class Searchad.Views.QueryItems.IndexView extends Backbone.View
  initialize: (options) =>
    
    _.bindAll(this, 'render', 'initTable')
    @controller = options.controller
    @collection = new Searchad.Collections.QueryItemsCollection()
    @initTable()

    @controller.bind('query_items:index', @initialLoad)
    @controller.bind('date_changed', @dateChangedLoad)
    @collection.bind('reset', @render)

  active: false

  template: JST["backbone/templates/query_items/tabs"]
  
  el: $('#query_items_tab')

  container: $('div.tab_children')

  gridColumns: =>
    class ItemCell extends Backgrid.Cell
      item_template: JST["backbone/templates/query_items/item"]
      
      render: =>
        item = @model.get(@column.get('name'))
        formatted_value = @item_template(item)
        $(@$el).html(formatted_value)
        return this
    
    columns = [{
    name: 'walmart_item',
    label: 'Store item',
    editable: false,
    cell: ItemCell},
    {name: 'rev_based_item',
    label: 'Top Rev Item',
    editable: false,
    cell: ItemCell}]

    columns

  initTable: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )

  render: =>
    $(@el).children().remove()
    $(@el).append(@template())
    $(@container).append( @grid.render().$el)
    return this

  initialLoad: (args) =>
    @active = true
    @collection.get_items(args)

  dateChangedLoad: (args) =>
    $(@el).children().remove()
    $(@container).children().remove()
