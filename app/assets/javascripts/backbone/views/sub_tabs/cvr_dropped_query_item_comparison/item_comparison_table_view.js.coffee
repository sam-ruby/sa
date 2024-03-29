###
Conversion Rate Dropping Query Item Comparison View
@author Linghua Jin
@since Dec, 2013
@class Searchad.Views.CVRDroppedQuery.ItemComparisonView
@extend Backbone.View

Item showed for a query comparison for before and after based on selected week range and time from adhoc_query_report. 
###

Searchad.Views.SubTabs ||= {}
Searchad.Views.SubTabs.ItemComparisonView ||= {}

class Searchad.Views.SubTabs.ItemComparisonView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @collection =
      new Searchad.Collections.CvrDroppedQueryComparisonItemCollection()
    # @controller.bind('date-changed', => @get_items() if @active)
    @collection.bind('reset', @render)
    @collection.bind('changed', @render)
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('sub-content-cleanup', @unrender)
    @controller.bind('search:sub-content-cleanup', @unrender)
    @collection.bind('request', =>
      @$el.children().not('ul').remove()
      @controller.trigger('search:sub-content:show-spin')
      @undelegateEvents()
    )
    Utils.InitExportCsv(this,
      '/search/get_cvr_dropped_query_item_comparison.csv')
    @undelegateEvents()
    @data = {}
    @active = false

  events: =>
    'click .export-csv a': (e) ->
      data =
         query_date:  @data.query_date
         query: @data.query.replace(/\s+/g, '_').replace(/"|'/, '')
         weeks_apart: @data.weeks_apart

      fileName = "item_comparison_#{data.query}_#{data.query_date}_week_apart_#{data.weeks_apart}.csv"
      @export_csv($(e.target), fileName, @data)
  
  gridColumns: =>
    if @collection.data_date_before
      before_items_label =
        "Item shown on #{new Date(@collection.data_date_before).toString(
          'MMM d, yyyy')}"
    else
      before_items_label =
        "Item list not present"

    if @collection.data_date_after
      after_items_label =
        "Item shown on #{new Date(@collection.data_date_after).toString(
          'MMM d, yyyy')}"
    else
      after_items_label =
        "Item list not present"

    class ItemCellBefore extends Backgrid.Cell
      item_template:
        JST["backbone/templates/poor_performing/walmart_items/item"]
      render: =>
        item =
          image_url: @model.get('image_url_before')
          item_id: @model.get('item_id_before')
          title: @model.get('item_title_before')
        formatted_value = @item_template(item)
        $(@$el).html(formatted_value)
        return this

    class ItemCellAfter extends Backgrid.Cell
      item_template:
        JST["backbone/templates/poor_performing/walmart_items/item"]
      
      render: =>
        item =
          image_url: @model.get('image_url_after')
          item_id: @model.get('item_id_after')
          title: @model.get('item_title_after')
        formatted_value = @item_template(item)
        $(@$el).html(formatted_value)
        return this

    columns = [{
    name: 'cvr_dropped_item_comparison_rank',
    label: 'Position',
    editable: false,
    cell: 'string'
    headerCell:'helperDescending'
    helpInfo: 'Position is the order of the items shown'
    },
    {
    name: 'item_title_before',
    label: before_items_label,
    editable: false,
    cell: ItemCellBefore
    },
    {
    name: 'seller_name_before',
    label: 'Seller',
    editable: false,
    cell: 'string'
    },
    {name: 'item_title_after',
    label: after_items_label,
    editable: false,
    cell: ItemCellAfter
    },
    {
    name: 'seller_name_after',
    label: 'Seller',
    editable: false,
    cell: 'string'
    }]
    
    columns

  initTable: =>
    @grid = new Backgrid.Grid(
      className:'query-dropped-item-comparison backgrid'
      columns: @gridColumns()
      collection: @collection
      emptyText: 'No Data'
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection)
    
  unrender: =>
    @$el.children().remove()
    @active = false
    @undelegateEvents()
  
  get_items: (data) =>
    @active = true
    @data = data
    @unrender

    # important,must reset current page size to 1
    @collection.state.currentPage = 1
    @collection.get_items(data)

  render: =>
    return unless @active
    @initTable()

    if @collection.size() == 0
      @$el.append(@grid.render().$el)
      return
    
    @$el.children().not('.ajax-loader').remove()
    @controller.trigger('search:sub-content:hide-spin')
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append(@export_csv_button())
    @delegateEvents()
    this
