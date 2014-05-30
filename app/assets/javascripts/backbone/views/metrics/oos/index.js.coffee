#= require backbone/views/metrics/index
#= require backbone/models/oos

class Searchad.Views.Oos extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('oos')

class Searchad.Views.Oos.Winners extends Searchad.Views.Oos
  initialize: (options) =>
    @collection = new Searchad.Collections.OosWinner()
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
    {name: 'o_o_s',
    label: 'Out of Stock',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'percent'},
    {name: 'c_o_n',
    label: 'Conversion',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'percent'},
    {name: 'p_v_r',
    label: 'Product View',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'percent'},
    {name: 'score',
    label: "Score",
    editable: false,
    sortType: 'toggle',
    headerCell: @SortedHeaderCell,
    cell: 'integer'}]

  
  render: =>
    @renderTable()

class Searchad.Views.Oos.Distribution extends Searchad.Views.Oos
  initialize: (options) ->
    @navBar = JST["backbone/templates/conv_cor_navbar"](title: 'Out of Stock')
    @collection = new Searchad.Collections.OosDistribution()
    super(options)
  
  render: =>
    @renderBarChart(@collection.toJSON(),
      'Out of Stock Rate',
      'Number of Queries',
      'Query Distribution over Out Of Stock Rate')
   
class Searchad.Views.Oos.Stats extends Searchad.Views.Oos
  initialize: (options) ->
    @collection = new Searchad.Collections.OosStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON(),
      'Out of Stock',
      'Out of Stock Statistics')
