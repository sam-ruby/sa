#= require backbone/views/base
class Searchad.Views.SummaryMetrics extends Searchad.Views.Base
  initialize: (options) ->
    @collection = new Searchad.Collections.SummaryMetric()
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'request', @prepare_for_render)
    super(options)
    
    @summary_template = JST["backbone/templates/overview"]
    @navBar = JST["backbone/templates/summary_metrics"]
    @carousel = @$el.parents('.carousel.slide')
    
    @listenTo(@router, 'route:search', (path, filter) =>
      if @router.date_changed or @router.cat_changed or !@active or @router.query_segment_changed
        @get_items()

      path? and (@segment = path.search)
      if path? and path.page? and path.page == 'overview'
        @carousel.carousel(0)
        @carousel.carousel('pause')
      else if path? and path.details? and path.details == '1'
        @carousel.carousel(2)
        @carousel.carousel('pause')
      else if path? and path.page? and path.page != 'overview'
        @carousel.carousel(1)
        @carousel.carousel('pause')
    )
  
  metrics_name:
    traffic:
      name: 'Traffic'
      id: 'traffic'
    pvr:
      name: 'Product View Rate'
      id: 'pvr'
    atc:
      name: 'Add To Cart Rate'
      id: 'atc'
    conversion:
      name: 'Conversion Rate'
      id: 'conversion'
    'relevance conversion correlation':
      name: 'Rel Conv Correlation'
      id: 'conv_cor'
    revenue:
      name: 'Revenue'
      id: 'revenue'
    FCT:
      name: 'Earliest Item Click'
      id: 'first_click'
      disabled: true
    LCT:
      name: 'Latest Item Click'
      id: 'latest_click'
      disabled: true
    QDT:
      name: 'Query Dwell Time'
      id: 'dwell_time'
      disabled: true
    CPQ:
      name: 'Clicks Per Query'
      id: 'clicks_query'
      disabled: true
    CAF:
      name: 'Clicks on First Item'
      id: 'clicks_f_item'
      disabled: true
    AR:
      name: 'Abandon Rate'
      id: 'aband_rate'
      disabled: true
    'count per session':
      name: 'Queries per Session'
      id: 'queries_session'
      disabled: true
    OOS:
      name: 'Out of Stock Rate'
      id: 'oos'
    MRR:
      name: 'Total Reciprocal Rank'
      id: 'mrr'
      disabled: true
    
  events: =>
    events = {}
    events['click .info'] = (e)=>
      e.preventDefault()
      if $(e.target).hasClass('info')
        metric = $(e.target).attr('class').replace(/(\s+)?info(\s+)?/, '')
        info = $(e.target)
      else
        metric = $(e.target).parents('.info').attr(
          'class').replace(/(\s+)?info(\s+)?/, '')
        info = $(e.target).parents('.info')
      icon = info.find('i')

      if icon.hasClass('icon-resize-horizontal')
        icon.removeClass('icon-resize-horizontal')
        icon.addClass('icon-resize-vertical')
        info.css('margin-bottom', '1em')
      else
        icon.removeClass('icon-resize-vertical')
        icon.addClass('icon-resize-horizontal')
        info.css('margin-bottom', '0')

      info.parents('div.overview').find(
        'div.metric.' + metric).toggle('slideup')

    events['click .conv-drop-periods button'] = (e) =>
      e.preventDefault()
      weeks = $(e.target).text()
      new_path = "search/drop_con_#{weeks}"
      $(e.target).parents('.btn-group').find('.btn.btn.primary').removeClass(
        'btn-primary')
      $(e.target).addClass('btn-primary')
      @router.update_path(new_path, trigger: true)

    events['click .trending-periods button'] = (e) =>
      days = $(e.target).text()
      new_path = "search/trend_#{days}"
      $(e.target).parents('.btn-group').find('.btn.btn.primary').removeClass(
        'btn-primary')
      $(e.target).addClass('btn-primary')
      @router.update_path(new_path, trigger: true)

    that = this
    for metric, details of @metrics_name
      metric_id = details.id
      disabled = (details.disabled == true)
      events["click div.#{metric_id} .metric-name"] = do (
        metric_id, disabled, that) ->
        (e) =>
          e.preventDefault()
          return if disabled
          $(e.target).parents('.overview').find(
            '.mrow.selected').removeClass('selected')
          $(e.target).parents('.mrow').addClass('selected')
          that.navigate(metric_id)
          
      events["click div.#{metric_id} .metric-queries"] = do (
        metric_id, disabled, that) ->
        (e) =>
          e.preventDefault()
          return if disabled
          $(e.target).parents('.overview').find(
            '.mrow.selected').removeClass('selected')
          $(e.target).parents('.mrow').addClass('selected')
          
          query = encodeURIComponent($(e.target).text())
          segment = that.segment
          feature = metric_id
          if query.match(/[\.]{3}/)
            that.router.update_path(
              "search/#{segment}/page/#{feature}", trigger: true)
          else
            that.router.update_path(
              "search/#{segment}/page/#{feature}/details/1/query/#{query}",
              trigger: true)

    events

  get_items: (data) =>
    @active = true
    @$el.find('ul.metrics').css('display', 'block')
    @collection.get_items()

  prepare_for_render: =>
    @$el.find('.ajax-loader').css('display', 'inline-block')
   
  render: =>
    return unless @active
    @$el.find('.ajax-loader').hide()
    @$el.children().not('.ajax-loader').hide()
    
    periods = []
    segment = ''
    if @segment? and (match = @segment.match(/trend_(\d+)/))
      days = parseInt(match[1])
      periods =
        2: (days == 2 ? true: false)
        7: (days == 7 ? true: false)
        14: (days == 14 ? true: false)
        21: (days == 21 ? true: false)
        28: (days == 28 ? true: false)
      segment = 'trending'
    else if @segment? and (
      (match = @segment.match(/poor_perform/)) or
      (match = @segment.match(/drop_con_(\d+)/)))
      weeks = parseInt(match[1])
      periods =
        1: (weeks == 1 ? true: false)
        2: (weeks == 2 ? true: false)
        3: (weeks == 3 ? true: false)
        4: (weeks == 4 ? true: false)
      segment = 'poor_performing'

    @$el.append( @navBar(
      periods: periods
      segment: segment) )

    metrics = @collection.toJSON()[0]
    general_metrics = ['traffic', 'conversion', 'OOS', 'pvr', 'atc', 'revenue' ]
    correl_metrics = ['relevance conversion correlation']
    user_engage_metrics = ['CAF', 'AR', 'count per session', 'QDT', 'FCT',
      'LCT', 'CPQ', 'MRR']

    overall_metrics =
      general:
        name: 'General'
        class: 'general'
        metrics: (metrics[m] for m in general_metrics when metrics[m]?)
      user_engage_metrics:
        name: 'User Engagement Metrics'
        class: 'user_eng'
        metrics: (metrics[m] for m in user_engage_metrics when metrics[m]?)
      correl_metrics:
        name: 'Relevance Evaluation Metrics'
        class: 'rel_eval'
        metrics: (metrics[m] for m in correl_metrics when metrics[m]?)
          
    @$el.append(@summary_template(
      metrics: overall_metrics
      segment: @segment
      view: this))

  unrender: =>
    @active = false

  navigate: (metric) =>
    query_segment = @router.path.search
    @router.update_path(
      "search/#{query_segment}/page/#{metric}", trigger: true)
