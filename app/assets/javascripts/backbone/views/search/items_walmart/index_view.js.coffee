Searchad.Views.Search ||= {}
Searchad.Views.Search.WalmartItems ||= {}

class Searchad.Views.Search.WalmartItems.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @collection =
      new Searchad.Collections.CAWalmartItemsCollection()
    @initTable()
    
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @collection.bind('reset', @render)
    
    @collection.bind('request', =>
      @$el.children().not('.ajax-loader').remove()
      @controller.trigger('search:sub-content:show-spin')
      @undelegateEvents()
    )

    @controller.bind('content-cleanup', @unrender)
    @controller.bind('sub-content-cleanup', @unrender)
    Utils.InitExportCsv(this, '/comp_analysis/get_walmart_items.json')
    @undelegateEvents()
    @active = false

  events: =>
    'click .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      query = @query.replace(/\s+/g, '_')
      query = query.replace(/"|'/, '')
      fileName = "walmart_search_results_#{query}_#{date}.csv"
      data =
        date: date
        query: @query
      @export_csv($(e.target), fileName, data)
  
  gridColumns: =>
    class ItemCell extends Backgrid.Cell
      item_template:
        JST["backbone/templates/poor_performing/walmart_items/item"]
      
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
    cell: 'number',
    formatter: Utils.CurrencyFormatter},
    {name: 'shown_count',
    label: I18n.t('dashboard2.shown_count'),
    editable: false,
    formatter: Utils.CustomNumberFormatter,
    cell: 'integer'},
    {name: 'item_con',
    label: I18n.t('perf_monitor2.conversion_rate'),
    editable: false,
    cell: 'number',
    formatter: Utils.PercentFormatter},
    {name: 'item_atc',
    label: I18n.t('perf_monitor2.add_to_cart_rate'),
    editable: false,
    cell: 'number',
    formatter: Utils.PercentFormatter},
    {name: 'item_pvr',
    label: I18n.t('perf_monitor.product_view_rate'),
    editable: false,
    cell: 'number',
    formatter: Utils.PercentFormatter}]
    
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
    @controller.trigger('search:sub-content:hide-spin')
    @undelegateEvents()
  
  get_items: (data) =>
    @active = true
    @query = data.query if data.query
    @collection.get_items(data)

  render_error: (query) ->
    return unless @active
    @controller.trigger('search:sub-content:hide-spin')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )
  
  render: =>
    return unless @active
    @controller.trigger('search:sub-content:hide-spin')
    return @render_error(@query) if @collection.size() == 0
    
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @export_csv_button() )
    @delegateEvents()
    return this
