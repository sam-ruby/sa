#= require backbone/views/conv_cor/index

class Searchad.Views.ConvCorrelation.Winners extends Searchad.Views.ConvCorrelation.Index
  initialize: (options) =>
    @collection = new Searchad.Collections.ConvCorWinners()
    super(options)
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'request', @prepare_for_render)
    @initTable()
    Utils.InitExportCsv(this, "/search_rel/get_search_words.csv")
    @active = false
        
  events:
    'click .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      fileName = "ndcg_winners_#{date}.csv"
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
      '<caption class="metrics-summary-head">Winners</caption>')

    @$el.append( @export_csv_button() ) unless @$el.find(
      '.export-csv').length > 0
    @delegateEvents()
    this
