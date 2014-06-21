#= require backbone/views/metrics/index
#= require backbone/models/p1_oos

class Searchad.Views.P1Oos extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('p1_oos')

class Searchad.Views.P1Oos.Winners extends Searchad.Views.P1Oos
  initialize: (options) =>
    @collection = new Searchad.Collections.P1OosWinner()
    @tableCaption = JST["backbone/templates/win_lose"]
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
    {name: 'o_o_s',
    label: 'Page 1 OOS Rate',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'percent'},
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
    {name: 'score',
    label: "Score",
    editable: false,
    sortType: 'toggle',
    headerCell: @SortedHeaderCell,
    cell: 'integer'}]

  render: =>
    @renderTable()
