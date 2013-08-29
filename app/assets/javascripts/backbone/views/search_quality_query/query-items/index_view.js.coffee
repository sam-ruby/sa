Searchad.Views.SearchQualityQuery.QueryItems ||= {}

class Searchad.Views.SearchQualityQuery.QueryItems.IndexView extends Backbone.View
  initialize: (options) =>
    
    _.bindAll(this, 'render', 'initTable')
    @controller = SearchQualityApp.Controller
    @collection = new Searchad.Collections.QueryItemsCollection()
    @initTable()
    
    @controller.bind('search-rel:query-items:index', @get_items)
    @controller.bind('search-rel:sub-content-cleanup', @unrender)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('reset', @render)

  active: false

  tab_el: $('#query-items-tab')

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
  
  get_items: (data) =>
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.get_items(data)
    
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection)

  render: =>
    @active = true
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    this
  
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
    this
