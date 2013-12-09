Searchad.Views.CVRDroppedQuery||= {}

class Searchad.Views.CVRDroppedQuery.ItemComparisonView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @collection =
      new Searchad.Collections.CvrDroppedQueryComparisonItemCollection()
    @initTable()
    
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @collection.bind('reset', @render)
    @collection.bind('changed', @render)
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('sub-content-cleanup', @unrender)
    Utils.InitExportCsv(this, '/search/get_cvr_dropped_query_item_comparison.json')
    @undelegateEvents()
    @data = {}
    @active = false

  events: =>
    'click .export-csv a': (e) ->
      data =
         query_date:  @data.query_date
         query: @data.query.replace(/\s+/g, '_').replace(/"|'/, '')
         weeks_apart: @data.weeks_apart

      fileName = "conversion_rate_dropped_item_comparison_for_#{data.query}_#{data.query_date}_week_apart_#{data.weeks_apart}.csv"
      @export_csv($(e.target), fileName, @data)
  
  gridColumns: =>
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
    name: 'item_title_before',
    label: 'Item Before',
    editable: false,
    cell: ItemCellBefore
    },
    {
    name: 'seller_id_before',
    label: 'Seller_ID',
    editable: false,
    cell: 'string'
    },
    {name: 'item_title_after',
    label: 'Item After', 
    editable: false,
    cell: ItemCellAfter
    },
    {
    name: 'seller_id_after',
    label: 'Seller_ID',
    editable: false,
    cell: 'string'
    }
    ]
    
    columns

  initTable: =>
    @grid = new Backgrid.Grid(
      className:'query-dropped-item-comparison backgrid'
      columns: @gridColumns()
      collection: @collection
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection)
    
  unrender: =>
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
    @active = false
    @undelegateEvents()
  
  get_items: (data) =>
    @data = data
    @unrender
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.get_items(data)

  render_error: (query) ->
    @controller.trigger('search:sub-content:hide-spin')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )
  
  render: =>
    @unrender()
    return @render_error(@data.query) if @collection.size() == 0
    @active = true
    @$el.append($('<div>').css('text-align', 'left').css(
      'margin-bottom': '1em').append(
      $('<i>').addClass('icon-eye-open').css(
        'font-size', 'large').append(
        '&nbsp; Item Comparison Results for  :  <strong>' + @data.query + '</strong>')))
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @export_csv_button() )
    @delegateEvents()
    return this


