#= require backbone/views/metrics/index
#= require backbone/models/pvr

class Searchad.Views.Pvr extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('pvr')

class Searchad.Views.Pvr.Winners extends Searchad.Views.Pvr
  initialize: (options) =>
    @collection = new Searchad.Collections.PvrWinner()
    @tableCaption = JST["backbone/templates/win_lose"]
    Utils.InitExportCsv(this, @collection.url + '.csv', 'pvr_oppt')
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
    
class Searchad.Views.Pvr.Distribution extends Searchad.Views.Pvr
  initialize: (options) ->
    @navBar = JST["backbone/templates/conv_cor_navbar"](title: 'Product View Rate')
    @collection = new Searchad.Collections.PvrDistribution()
    super(options)
 
  render: =>
    @renderBarChart(@collection.toJSON(),
      'Product View Rate',
      'Number of Queries',
      'Query Distribution over Product View Rate')

class Searchad.Views.Pvr.Stats extends Searchad.Views.Pvr
  initialize: (options) ->
    @collection = new Searchad.Collections.PvrStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON(),
      'Product View Rate',
      'Product View Rate Statistics')

