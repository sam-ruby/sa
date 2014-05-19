#= require backbone/views/metrics/index
#= require backbone/models/traffic

class Searchad.Views.Traffic extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('traffic')

class Searchad.Views.Traffic.Winners extends Searchad.Views.Traffic
  initialize: (options) =>
    @collection = new Searchad.Collections.TrafficWinner()
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
    label: 'Count',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'integer'},
    {name: 'c_o_n',
    label: 'Conversion',
    editable: false,
    headerCell: @NumericHeaderCell,
    formatter: @PercentFormatter,
    cell: 'number'},
    {name: 'p_v_r',
    label: 'Product View',
    editable: false,
    headerCell: @NumericHeaderCell,
    formatter: @PercentFormatter,
    cell: 'number'},
    {name: 'a_t_c',
    label: 'Add To Cart',
    editable: false,
    headerCell: @NumericHeaderCell,
    formatter: @PercentFormatter,
    cell: 'number'},
    {name: 'score',
    label: "Score",
    editable: false,
    sortType: 'toggle',
    headerCell: @SortedHeaderCell,
    cell: 'integer'}]

  
  render: =>
    @renderTable()

class Searchad.Views.Traffic.Distribution extends Searchad.Views.Traffic
  initialize: (options) ->
    @navBar = JST["backbone/templates/conv_cor_navbar"](title: 'Traffic')
    @collection = new Searchad.Collections.TrafficDistribution()
    super(options)
  
  render: =>
    @renderBarChart(@collection.toJSON(),
      'Count',
      'Number of Queries',
      'Query Distribution over Traffic')
   
class Searchad.Views.Traffic.Stats extends Searchad.Views.Traffic
  initialize: (options) ->
    @collection = new Searchad.Collections.TrafficStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON(),
      'Traffic',
      'Traffic Statistics')
