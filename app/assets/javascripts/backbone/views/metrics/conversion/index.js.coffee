#= require backbone/views/metrics/index
#= require backbone/models/conversion

class Searchad.Views.Conversion extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('conversion')

class Searchad.Views.Conversion.Winners extends Searchad.Views.Conversion
  initialize: (options) =>
    @collection = new Searchad.Collections.ConversionWinner()
    @tableCaption = JST["backbone/templates/win_lose"]
    super(options)
    @init_table()
    Utils.InitExportCsv(this, "/search_rel/get_search_words.csv")
 
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
    label: "Score",
    editable: false,
    sortType: 'toggle',
    headerCell: @SortedHeaderCell,
    cell: 'integer'}]

  render: =>
    @renderTable()
    
class Searchad.Views.Conversion.Distribution extends Searchad.Views.Conversion
  initialize: (options) ->
    @navBar = JST["backbone/templates/conv_cor_navbar"](title: 'Conversion')
    @collection = new Searchad.Collections.ConversionDistribution()
    super(options)
    
  render: =>
    @renderBarChart(@collection.toJSON(),
      'Conversion Rate',
      'Number of Queries',
      'Query Distribution over Conversion Rate')

class Searchad.Views.Conversion.Stats extends Searchad.Views.Conversion
  initialize: (options) ->
    @collection = new Searchad.Collections.ConversionStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON(),
      'Conversion Rate',
      'Conversion Rate Statistics')
