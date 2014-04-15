#= require backbone/views/base
#
Searchad.Views.SubTabs ||= {}
Searchad.Views.SubTabs.RelRev ||= {}

class Searchad.Views.SubTabs.RelRev.IndexView extends Searchad.Views.Base
  initialize: (options) =>
    _.bindAll(this, 'render', 'initTable')
    @collection = new Searchad.Collections.QueryItemsCollection()
    super(options)
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
    set_walmart_item = (view) ->
      if view.column.get('walmart_detail')
        view.$el.addClass('walmart-detail')
      else
        view.$el.addClass('best-seller-detail')

    class ItemCell extends Backgrid.Cell
      item_template:
        JST["backbone/templates/search_quality_query/query_items/item"]
      render: =>
        set_walmart_item(this)
        item = @model.get(@column.get('name'))
        formatted_value = @item_template(item)
        $(@$el).html(formatted_value)
        unless @column.get('walmart_detail')
          @$el.addClass('best-seller-detail-first')
        this

    class MyIntegerCell extends Backgrid.IntegerCell
      render: =>
        set_walmart_item(this)
        super()
        this

    class MyItemCell extends ItemCell
      render: =>
        super()
        @$el.addClass('best-seller-detail-first')
        this
    
    class MyOosCell extends @OosCell
      render: =>
        set_walmart_item(this)
        super()
        if @column.get('walmart_detail')
          @$el.addClass('walmart-detail-last')
        else
          @$el.addClass('best-seller-detail-last')

        this

    columns = [{
    name: 'position',
    label: 'Position',
    headerCell: @NumericHeaderCell,
    editable: false,
    sortable: false,
    walmart_detail: true,
    cell: MyIntegerCell},
    {name: 'walmart_item',
    label: 'Relevance Order',
    editable: false,
    sortable: false,
    walmart_detail: true,
    cell: ItemCell},
    {name: 'con_rank',
    label: 'Conv Rank',
    editable: false,
    sortable: false,
    headerCell: @NumericHeaderCell,
    walmart_detail: true,
    cell: MyIntegerCell},
    {name: 'w_oos',
    label: 'Out of Stock Rate',
    headerCell: @NumericHeaderCell,
    editable: false,
    walmart_detail: true,
    cell: MyOosCell},
    {name: 'con_based_item',
    label: 'Best Seller Order',
    editable: false,
    sortable: false,
    cell: MyItemCell},
    {name: 'con',
    label: 'Order Count',
    headerCell: @NumericHeaderCell,
    editable: false,
    sortable: false,
    formatter: Utils.CustomNumberFormatterNoDecimals,
    cell: MyIntegerCell},
    {name: 'c_oos',
    label: 'Out of Stock Rate',
    headerCell: @NumericHeaderCell,
    editable: false,
    cell: MyOosCell}
    ]

    columns

  initTable: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
      className: 'winners-grid'
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
