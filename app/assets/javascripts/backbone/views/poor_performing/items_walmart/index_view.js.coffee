Searchad.Views.PoorPerforming.WalmartItems ||= {}

class Searchad.Views.PoorPerforming.WalmartItems.IndexView extends Backbone.View
  initialize: (options) =>
    
    _.bindAll(this, 'render')
    @controller = SearchQualityApp.Controller
    @collection =
      new Searchad.Collections.PoorPerfWalmartItemsCollection()
    @initTable()
    
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @collection.bind('reset', @render)
    @controller.bind('content-cleanup', @unrender)

  active: false

  template: JST["backbone/templates/query_items/tabs"]
  
  tab_el: $('#query-items-tab')

  gridColumns: =>
    class ItemCell extends Backgrid.Cell
      item_template: JST["backbone/templates/poor_performing/walmart_items/item"]
      
      render: =>
        item =
          image_url: @model.get('image_url')
          item_id: @model.get('item_id')
          title: @model.get('title')
        
        formatted_value = @item_template(item)
        $(@$el).html(formatted_value)
        return this

    columns = [{
    name: 'item_id',
    label: I18n.t('dashboard2.item'),
    editable: false,
    cell: ItemCell},
    {name: 'item_revenue',
    label: I18n.t('dashboard2.revenue'),
    editable: false,
    cell: 'number'},
    {name: 'shown_count',
    label: I18n.t('dashboard2.shown_count'),
    editable: false,
    cell: 'string'},
    {name: 'item_con',
    label: I18n.t('perf_monitor2.conversion_rate'),
    editable: false,
    cell: 'number'},
    {name: 'item_atc',
    label: I18n.t('perf_monitor2.add_to_cart_rate'),
    editable: false,
    cell: 'number'},
    {name: 'item_pvr',
    label: I18n.t('perf_monitor.product_view_rate'),
    editable: false,
    cell: 'number'}]
    
    columns

  initTable: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection)
    
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()

  get_items: (data) =>
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.get_items(data)

  render: =>
    @active = true
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    return this
