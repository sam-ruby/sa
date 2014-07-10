#= require backbone/views/metrics/index

class Searchad.Views.EvalMetrics extends Searchad.Views.Metrics.Index
  initialize: ->
    @collection = new Searchad.Collections.NdcgWinner()
    @tableCaption = JST["backbone/templates/win_lose"]
    eval_paths = ['e_ndcg_5', 'e_ndcg_16', 'e_ndcg_1', 'e_prec_1', 'e_prec_5',
      'e_prec_16', 'e_recall_1', 'e_recall_5', 'e_recall_16']
    
    super(eval_paths)
    @current_metic = null
    
    @stopListening(@router, 'route:search')
    @listenTo(@router, 'route:search', (path, filter) =>
      if @router.date_changed or @router.cat_changed or @router.query_segment_changed or (@router.path? and @router.path.page? and (@router.path.page in eval_paths) and (@router.path.page != @current_metric))
        @dirty = true
        @current_metric = @router.path.page
      
      if (path.page in eval_paths) and !path.details?
        @cleanup()
        @renderTable()
        for metric, m_details of Searchad.Views.SummaryMetrics.prototype.metrics_name when m_details.id == path.page
          metric_name = m_details.name
          @controller.send_event(metric_name, 'Opportunity Load')
        @get_items() if @dirty
    )

  grid_cols: =>
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
