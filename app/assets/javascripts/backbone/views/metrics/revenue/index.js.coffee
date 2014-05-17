#= require backbone/views/metrics/index
#= require backbone/models/revenue

class Searchad.Views.Revenue extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('revenue')

class Searchad.Views.Revenue.Winners extends Searchad.Views.Revenue
  initialize: (options) =>
    @collection = new Searchad.Collections.RevenueWinner()
    @tableCaption = JST["backbone/templates/win_lose"]
    Utils.InitExportCsv(this, "/search_rel/get_search_words.csv")
    super(options)
 
  grid_cols: =>
    [{name: 'query',
    label: 'Query',
    editable: false,
    headerCell: @QueryHeaderCell,
    cell: @QueryCell},
    {name: 'c_o_u_n_t',
    label: 'Count',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'integer'},
    {name: 'c_o_n',
    label: 'Conversion Rate',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: @PercentCell},
    {name: 'p_v_r',
    label: 'Product View Rate',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: @PercentCell},
    {name: 'a_t_c',
    label: 'Add To Cart Rate',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: @PercentCell},
    {name: 'score',
    label: "Revenue",
    editable: false,
    sortType: 'toggle',
    headerCell: @SortedHeaderCell,
    cell: 'integer'}]

  render: =>
    @renderTable()
    
class Searchad.Views.Revenue.Distribution extends Searchad.Views.Revenue
  initialize: (options) ->
    @navBar = JST["backbone/templates/conv_cor_navbar"](title: 'Revenue')
    @collection = new Searchad.Collections.RevenueDistribution()
    super(options)
    
  render: =>
    @renderBarChart(@collection.toJSON(),
      'Revenue',
      'Number of Queries',
      'Query Distribution over Revenue')

class Searchad.Views.Revenue.Stats extends Searchad.Views.Revenue
  initialize: (options) ->
    @collection = new Searchad.Collections.RevenueStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON(),
      'Revenue',
      'Revenue Statistics')
