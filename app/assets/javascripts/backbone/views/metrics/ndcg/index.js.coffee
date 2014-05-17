#= require backbone/views/metrics/index

class Searchad.Views.ONdcg extends Searchad.Views.Metrics.Index
  initialize: (feature_path) ->
    @collection = new Searchad.Collections.ONdcgWinner()
    @tableCaption = JST["backbone/templates/win_lose"]
    for metric_db_id, metric_details of Searchad.Views.SummaryMetrics.prototype.metrics_name when metric_details.id == feature_path
      @metric_label = metric_details.name
    Utils.InitExportCsv(this, "/search_rel/get_search_words.csv")
    super(feature_path)

  grid_cols: =>
    if @metric_label?
      metric_label = @metric_label
    else
      metric_label = 'Metric Value'

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
    label: metric_label,
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'number'},
    {name: 'c_o_n',
    label: 'Conversion',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: @PercentCell},
    {name: 'p_v_r',
    label: 'Product View',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: @PercentCell},
    {name: 'a_t_c',
    label: 'Add To Cart',
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
