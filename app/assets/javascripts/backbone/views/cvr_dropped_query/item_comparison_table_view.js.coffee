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
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('sub-content-cleanup', @unrender)
    # Utils.InitExportCsv(this, '/comp_analysis/get_walmart_items.json')
    @undelegateEvents()
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
    # class ItemCell extends Backgrid.Cell
    #   item_template:
    #     JST["backbone/templates/poor_performing/walmart_items/item"]
      
    #   render: =>
    #     item =
    #       image_url: @model.get('image_url')
    #       item_id: @model.get('item_id')
    #       title: @model.get('title')
        
    #     formatted_value = @item_template(item)
    #     $(@$el).html(formatted_value)
    #     return this

    columns = [{
    name: 'before_item_id',
    label: 'before item id',
    editable: false,
    cell: 'number'},
    {name: 'after_item_id',
    label: 'after item id', 
    editable: false,
    cell: 'number',
    }]
    
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
    @undelegateEvents()
  
  get_items: (data) =>
    @query = data.query if data.query
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
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    # @$el.append( @export_csv_button() )
    @delegateEvents()
    return this
