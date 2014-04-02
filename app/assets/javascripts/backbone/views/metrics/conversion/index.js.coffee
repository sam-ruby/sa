#= require backbone/views/metrics/index
#= require backbone/models/conversion

class Searchad.Views.Conversion extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('conversion')

class Searchad.Views.Conversion.Winners extends Searchad.Views.Conversion
  initialize: (options) =>
    @collection = new Searchad.Collections.ConversionWinner()
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
    {name: 'uniq_con',
    label: 'Query Conversion',
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
    
class Searchad.Views.Conversion.Distribution extends Searchad.Views.Conversion
  initialize: (options) ->
    @navBar = JST["backbone/templates/conv_cor_navbar"](title: 'Conversion')
    @collection = new Searchad.Collections.ConversionDistribution()
    super(options)
    
  render: =>
    @renderBarChart(@collection.toJSON())

class Searchad.Views.Conversion.Stats extends Searchad.Views.Conversion
  initialize: (options) ->
    @collection = new Searchad.Collections.ConversionStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON())

