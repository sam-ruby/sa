#= require backbone/views/metrics/index
#= require backbone/models/atc

class Searchad.Views.Atc extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('atc')

class Searchad.Views.Atc.Winners extends Searchad.Views.Atc
  initialize: (options) =>
    @collection = new Searchad.Collections.AtcWinner()
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
    {name: 'uniq_atc',
    label: 'Query ATC',
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
    
class Searchad.Views.Atc.Distribution extends Searchad.Views.Atc
  initialize: (options) ->
    @navBar = JST["backbone/templates/conv_cor_navbar"](title: 'ATC')
    @collection = new Searchad.Collections.AtcDistribution()
    super(options)
    
  render: =>
    @renderBarChart(@collection.toJSON())

class Searchad.Views.Atc.Stats extends Searchad.Views.Atc
  initialize: (options) ->
    @collection = new Searchad.Collections.AtcStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON())

