#= require backbone/views/metrics/index

class Searchad.Views.ConvCorrelation extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('conv_cor')

class Searchad.Views.ConvCorrelation.Winners extends Searchad.Views.ConvCorrelation
  initialize: (options) =>
    @collection = new Searchad.Collections.ConvCorWinners()
    super(options)
    @init_cols()
    @init_table()
    Utils.InitExportCsv(this, "/search_rel/get_search_words.csv")
        
  grid_cols: =>
    [{name: 'query',
    label: I18n.t('search_analytics.query_string'),
    editable: false,
    headerCell: @QueryHeaderCell,
    cell: @QueryCell},
    {name: 'count',
    label: I18n.t('search_analytics.query_count'),
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'integer'},
    {name: 'correlation',
    label: 'Conv Correlation',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'number'},
    {name: 'score',
    label: "Conv Correlation Score",
    editable: false,
    sortType: 'toggle',
    headerCell: @SortedHeaderCell,
    cell: 'integer'}]

  render: =>
    @renderTable()
    
class Searchad.Views.ConvCorrelation.Distribution extends Searchad.Views.ConvCorrelation
  initialize: (options) ->
    @navBar = JST["backbone/templates/conv_cor_navbar"](title: 'Conv Relevance Details')
    @collection = new Searchad.Collections.ConvCorDistribution()
    super(options)
    
  render: =>
    @renderBarChart(@collection.toJSON())

class Searchad.Views.ConvCorrelation.Stats extends Searchad.Views.ConvCorrelation
  initialize: (options) ->
    @collection = new Searchad.Collections.ConvCorStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON(),
      'Conv Relevance Correlation Score',
      'Score')

