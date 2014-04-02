#= require backbone/views/metrics/index
#= require backbone/models/traffic

class Searchad.Views.Traffic extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('traffic')

class Searchad.Views.Traffic.Winners extends Searchad.Views.Traffic
  initialize: (options) =>
    @collection = new Searchad.Collections.TrafficWinner()
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
    {name: 'score',
    label: "Query Count",
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
    @renderBarChart(@collection.toJSON())

class Searchad.Views.Traffic.Stats extends Searchad.Views.Traffic
  initialize: (options) ->
    @collection = new Searchad.Collections.TrafficStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON())

