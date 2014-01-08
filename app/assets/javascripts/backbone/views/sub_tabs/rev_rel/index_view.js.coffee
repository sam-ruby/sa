Searchad.Views.SubTabs ||= {}
Searchad.Views.SubTabs.RelRev ||= {}

class Searchad.Views.SubTabs.RelRev.IndexView extends Backbone.View
  initialize: (options) =>
    
    _.bindAll(this, 'render', 'initTable')
    @controller = SearchQualityApp.Controller
    @collection = new Searchad.Collections.QueryItemsCollection()
    @initTable()
    
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @controller.bind('sub-content-cleanup', @unrender)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('reset', @render)
    @collection.bind('request', =>
      @$el.children().not('.ajax-loader').remove()
      @controller.trigger('search:sub-content:show-spin')
      @undelegateEvents()
    )
    Utils.InitExportCsv(this, '/search_rel/get_query_items.csv')
    @undelegateEvents()
    @active = false

  events: =>
    'click .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      query = @query.replace(/\s+/g, '_')
      query = query.replace(/"|'/, '')
      fileName = "relevance_best_seller_#{query}_#{date}.csv"
      data =
        date: date
        query: @query
      @export_csv($(e.target), fileName, data)
  
  gridColumns: =>
    class ItemCell extends Backgrid.Cell
      item_template:
        JST["backbone/templates/search_quality_query/query_items/item"]
      render: =>
        item = @model.get(@column.get('name'))
        formatted_value = @item_template(item)
        $(@$el).html(formatted_value)
        return this
    
    columns = [{
    name: 'position',
    label: 'Position',
    editable: false,
    sortable: false,
    cell: 'integer'},
    {name: 'walmart_item',
    label: 'Relevance Order',
    editable: false,
    sortable: false,
    cell: ItemCell},
    {name: 'rev_rank',
    label: 'Revenue Rank',
    editable: false,
    sortable: false,
    cell: 'integer'},
    {name: 'rev_based_item',
    label: 'Best Seller Order',
    editable: false,
    sortable: false,
    cell: ItemCell},
    {name: 'revenue',
    label: 'Revenue',
    editable: false,
    sortable: false,
    formatter: Utils.CurrencyFormatter,
    headerCell: 'helper',
    cell: 'number'},
    {name: 'site_revenue',
    label: 'Site Revenue',
    editable: false,
    sortable: false,
    formatter: Utils.CurrencyFormatter,
    headerCell: 'helper',
    cell: 'number'}]

    columns

  initTable: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection)
  
  get_items: (data) =>
    @active = true
    data || = { }
    if data.query
      @query = data.query
    else
      data.query = @query
    data.view || = "daily"
    @collection.get_items(data)

  render_error: (query) ->
    return unless @active
    
    @controller.trigger('search:sub-content:hide-spin')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )
  
  render: =>
    return unless @active
    return @render_error(@query) if @collection.size() == 0
    
    @$el.children().not('.ajax-loader').remove()
    @controller.trigger('search:sub-content:hide-spin')
    
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @export_csv_button() )
    @delegateEvents()
    this
  
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @controller.trigger('search:sub-content:hide-spin')
    @undelegateEvents()
