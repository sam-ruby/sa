#= require backbone/views/ndcg/index
class Searchad.Views.NDCG.Loosers extends Searchad.Views.NDCG.Index

  initialize: (options) =>
    @collection = new Searchad.Collections.NDCGLoosers()
    super(options)
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'request', @prepare_for_render)
    @initTable()
    Utils.InitExportCsv(this, "/search_rel/get_search_words.csv")
    @active = false
        
  events:
    'click .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      fileName = "ndcg_loosers_#{date}.csv"
      data =
        date: date
      data['query'] = @collection.data.query if @collection.data.query
      @export_csv($(e.target), fileName, data)
  
  initTable: () =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
      emptyText: 'No Data'
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )

  get_items: (data) =>
    @active = true
    @collection.get_items()

  render: =>
    return unless @active
    if @collection.size() == 0
      @$el.prepend( @grid.render() )
      return
    else
      @$el.prepend( @paginator.render().$el )
      @$el.prepend( @grid.render().$el )
    
    @$el.find('table.backgrid').append(
      '<caption class="metrics-summary-head">Loosers</caption>')

    @$el.append( @export_csv_button() ) unless @$el.find(
      '.export-csv').length > 0
    @delegateEvents()
    this
