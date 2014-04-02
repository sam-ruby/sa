#= require backbone/views/metrics/index
#= require backbone/models/pvr

class Searchad.Views.Pvr extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('pvr')

class Searchad.Views.Pvr.Winners extends Searchad.Views.Pvr
  initialize: (options) =>
    @collection = new Searchad.Collections.PvrWinner()
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
    {name: 'uniq_count',
    label: 'Query Count',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'integer'},
    {name: 'uniq_pvr',
    label: 'Query PVR',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'number'},
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
    @navBar = JST["backbone/templates/conv_cor_navbar"](title: 'PVR')
    @collection = new Searchad.Collections.PvrDistribution()
    super(options)
    
  render: =>
    @renderBarChart(@collection.toJSON())

class Searchad.Views.Pvr.Stats extends Searchad.Views.Pvr
  initialize: (options) ->
    @collection = new Searchad.Collections.PvrStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON())

