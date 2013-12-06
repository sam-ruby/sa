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
    # Utils.InitExportCsv(this, '/comp_analysis/get_walmart_items.json')
    @undelegateEvents()
    @query = {}
    @active = false

  events: =>
    # 'click .export-csv a': (e) ->
    #   date = @controller.get_filter_params().date
    #   query = @query.replace(/\s+/g, '_')
    #   query = query.replace(/"|'/, '')
    #   fileName = "walmart_search_results_#{query}_#{date}.csv"
    #   data =
    #     date: date
    #     query: @query
    #   @export_csv($(e.target), fileName, data)
  
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

    # Backgrid.WalmartItemCell.data = @model; 

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
    label: 'Seller_ID Before',
    editable: false,
    cell: 'number'
    },
    {name: 'item_title_after',
    label: 'Item After', 
    editable: false,
    cell: ItemCellAfter
    },
    {
    name: 'seller_id_after',
    label: 'Seller_ID After',
    editable: false,
    cell: 'number'
    }
    ]
    
    columns

  initTable: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection)
    
  unrender: =>
    console.log('unrender');
    console.log(@$el);
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
    @active = false
    @undelegateEvents()
  
  get_items: (data) =>
    console.log('get_items')

    @query = data.query if data.query
    @unrender
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.get_items(data)

  render_error: (query) ->
    @controller.trigger('search:sub-content:hide-spin')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )
  
  render: =>
    @unrender()
    return @render_error(@query) if @collection.size() == 0
    @active = true
    @$el.append($('<div>').css('text-align', 'left').css(
      'margin-bottom': '1em').append(
      $('<i>').addClass('icon-eye-open').css(
        'font-size', 'large').append(
        '&nbsp; Item Comparison Results for  :  <strong>' + @query + '</strong>')))
    # append('Item Comparison Results for '+ @query)
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    # @$el.append( @export_csv_button() )
    @delegateEvents()
    return this
