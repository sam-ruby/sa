#= require backbone/views/metrics/index
#= require backbone/models/atc

class Searchad.Views.Atc extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('atc')

class Searchad.Views.Atc.Winners extends Searchad.Views.Atc
  initialize: (options) =>
    @collection = new Searchad.Collections.AtcWinner()
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
    label: 'Conversion Rate',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'percent'},
    {name: 'p_v_r',
    label: 'Product View Rate',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'percent'},
    {name: 'a_t_c',
    label: 'Add To Cart Rate',
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
    
class Searchad.Views.Atc.Distribution extends Searchad.Views.Atc
  initialize: (options) ->
    @navBar = JST["backbone/templates/conv_cor_navbar"](title: 'Add To Cart Rate')
    @collection = new Searchad.Collections.AtcDistribution()
    super(options)
    
  render: =>
    @renderBarChart(@collection.toJSON(),
      'Add To Cart Rate',
      'Number of Queries',
      'Query Distribution over Add To Cart Rate')


class Searchad.Views.Atc.Stats extends Searchad.Views.Atc
  initialize: (options) ->
    @collection = new Searchad.Collections.AtcStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON(),
      'Add To Cart Rate',
      'Add To Cart Rate Statistics')

