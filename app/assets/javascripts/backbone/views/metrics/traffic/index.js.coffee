#= require backbone/views/metrics/index
#= require backbone/models/traffic

class Searchad.Views.Traffic extends Searchad.Views.Metrics.Index
  initialize: (options) ->
    super('traffic')

class Searchad.Views.Traffic.Winners extends Searchad.Views.Traffic
  initialize: (options) =>
    @collection = new Searchad.Collections.TrafficWinner()
    @tableCaption = JST["backbone/templates/win_lose"]
    super(options)
    @init_table()
    Utils.InitExportCsv(this, "/search_rel/get_search_words.csv")
 
  events: =>
    events = super()
    events['click caption.win-loose-head li.winners a'] = (e) =>
      e.preventDefault()
      @winning = true
      @toggle_tab(e)
      @active = true
      @collection.winning = true
      @collection.get_items()

    events['click caption.win-loose-head li.loosers a'] = (e) =>
      e.preventDefault()
      @winning = false
      @toggle_tab(e)
      @active = true
      @collection.winning = false
      @collection.get_items()
    events
    
  grid_cols: =>
    [{name: 'query',
    label: I18n.t('search_analytics.query_string'),
    editable: false,
    headerCell: @QueryHeaderCell,
    cell: @QueryCell},
    {name: 'p_v_r',
    label: 'Product View Rate',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: @PercentCell},
    {name: 'a_t_c',
    label: 'Add To Cart Rate',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: @PercentCell},
    {name: 'c_o_n',
    label: 'Conversion Rate',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: @PercentCell},
    {name: 'score',
    label: "Count",
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
    @$el.find('.carousel').show()
    @renderBarChart(@collection.toJSON(),
      'Query Traffic Bucket',
      'Number of Queries',
      'Query Distribution over Query Traffic')
   
    @$el.find('.carousel').on('slid', =>
      active_slide = @$el.find('.carousel-inner div.active')
      if active_slide.hasClass('distribution')
        @$el.find('.tab-holder li.active').removeClass('active')
        @$el.find('.tab-holder li.distribution').addClass('active')
      else if active_slide.hasClass('timeline')
        @$el.find('.tab-holder li.active').removeClass('active')
        @$el.find('.tab-holder li.timeline').addClass('active')
    )
  unrender: =>
    @$el.find('.carousel').hide()


class Searchad.Views.Traffic.Stats extends Searchad.Views.Traffic
  initialize: (options) ->
    @collection = new Searchad.Collections.TrafficStats()
    super(options)
   
   render: =>
    @renderLineChart(@collection.toJSON(),
      'Query Traffic',
      'Query Traffic Statistics')

