#= require backbone/views/metrics/index
class Searchad.Views.UEMetrics extends Searchad.Views.Metrics.Index
  initialize: ->
    @collection = new Searchad.Collections.NdcgWinner()
    @tableCaption = JST["backbone/templates/win_lose"]
    ue_paths = ['clicks_f_item', 'aband_rate',
      'dwell_time', 'first_click', 'latest_click', 'clicks_query',
      'mrr', 'qrr']
    
    super(ue_paths)
    @current_metic = null
    
    @stopListening(@router, 'route:search')
    @listenTo(@router, 'route:search', (path, filter) =>
      if @router.date_changed or @router.cat_changed or @router.query_segment_changed or (@router.path? and @router.path.page? and (@router.path.page in ue_paths) and (@router.path.page != @current_metric))
        @dirty = true
        @current_metric = @router.path.page
      
      if (path.page in ue_paths) and !path.details?
        @cleanup()
        @renderTable()
        @get_items() if @dirty
    )

  grid_cols: =>
    view = this
    get_col_label = =>
      metric_label = 'Metric Value'
      for metric_db_id, metric_details of Searchad.Views.SummaryMetrics.prototype.metrics_name when metric_details.id == @router.path.page
        metric_label = metric_details.name
        break
      metric_label

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
    {name: 'metric_value',
    label: get_col_label,
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'number'},
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
    {name: 'a_t_c',
    label: 'Add To Cart',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'percent'},
    {name: 'score',
    label: "Score",
    editable: false,
    cell: 'integer'}]

  render: =>
    @renderTable()
