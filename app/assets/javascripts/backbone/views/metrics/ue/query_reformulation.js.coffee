#= require backbone/views/metrics/index
#= require backbone/models/query_reform
class Searchad.Views.QueryReformulation extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super()
    @listenTo(@router, 'route:search', (path, filter) =>
      if @router.date_changed or @router.cat_changed or @router.query_segment_changed or (path.query? and path.query != @query)
        @collection.query = @query = path.query
        @dirty = true

      if path.details == 'query_reform' and path.query?
        window.scrollTo(0, 0)
        @cleanup()
        @renderTable()
        @queryStatsCollection.query = @query
        @queryStatsCollection.get_items()
        @get_items(
          query: @query
        ) if @dirty
    )

class Searchad.Views.QueryReformulation.Winners extends Searchad.Views.QueryReformulation
  initialize: (options) =>
    @collection = new Searchad.Collections.QueryReformulation()
    @tableCaption = JST["backbone/templates/query_reform"]
    @query_stats_template = JST['backbone/templates/query_stats']
    @queryStatsCollection =
      new Searchad.Collections.QueryStatsDailyCollection()
    @queryStatsCollection.bind('reset', @render_query_info)
    @queryStatsCollection.bind('error', @render_query_info)
    super(options)
 
  grid_cols: =>
    [{name: 'reformulatedQuery',
    label: 'Reformulated Query',
    editable: false,
    headerCell: @QueryHeaderCell,
    cell: @QueryCell},
    {name: 'NumberOfTimesReformulated2ThisForm',
    label: 'Traffic',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'integer'},
    {name: 'NumberOfTimesReformulated',
    label: 'Total Reformulations',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'integer'},
    {name: '%reformulations2thisQuery',
    label: 'Percentage of Reformulations',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'percent'}]
    
  render: =>
    @renderTable()
  
  render_query_info: =>
    metric = @queryStatsCollection.toJSON()[0]
    metric = {}  if !metric?
    metric.query = @query
    @$el.prepend(@query_stats_template(
      metric: metric))
