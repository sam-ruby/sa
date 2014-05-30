#= require backbone/views/metrics/index

class Searchad.Views.ConvCorrelation extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('conv_cor')

class Searchad.Views.ConvCorrelation.Winners extends Searchad.Views.ConvCorrelation
  initialize: (options) =>
    @collection = new Searchad.Collections.ConvCorWinners()
    @tableCaption = JST["backbone/templates/win_lose"]
    Utils.InitExportCsv(this, "/search_rel/get_search_words.csv")
    super(options)
        
  grid_cols: =>
    [{name: 'query',
    label: I18n.t('search_analytics.query_string'),
    editable: false,
    headerCell: @QueryHeaderCell,
    cell: @QueryCell},
    {name: 'c_o_u_n_t',
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
    @renderBarChart(@collection.toJSON(),
      'Rel Conv Correlation',
      'Number of Queries',
      'Query Distribution over Rel Conv Correlation Rate')

class Searchad.Views.ConvCorrelation.Stats extends Searchad.Views.ConvCorrelation
  initialize: (options) ->
    @collection = new Searchad.Collections.ConvCorStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON(),
      'Rel Conv Correlation',
      'Rel Conv Correlation Statistics')

