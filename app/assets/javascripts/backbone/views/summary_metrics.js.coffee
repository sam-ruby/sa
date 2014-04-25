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
    @segment_lookup = Searchad.Views.SearchTabs.IndexView.prototype.segment_lookup
    
    @listenTo(@router, 'route:search', (path, filter) =>
      if path? and path.page? and path.page.match(/overview/i)
        if @router.date_changed or @router.cat_changed or !@active or @router.query_segment_changed
          @get_items()
    )
  
  metrics_name:
    traffic:
      name: 'Traffic'
      id: 'traffic'
      cat: 'general'
    conversion:
      name: 'Conversion Rate'
      id: 'conversion'
      cat: 'general'
    OOS:
      name: 'Out of Stock Rate'
      id: 'oos'
      cat: 'general'
    P1_OOS:
      name: 'Page 1 OOS Rate'
      id: 'p1_oos'
      cat: 'general'
    pvr:
      name: 'Product View Rate'
      id: 'pvr'
      cat: 'general'
    atc:
      name: 'Add To Cart Rate'
      id: 'atc'
      cat: 'general'
    orders_ndcg_5:
      name: 'Orders NDCG@5'
      id: 'o_ndcg_5'
      cat: 'rel_eval'
      disabled: true
    orders_mpr_5:
      name: 'Orders MPR@5'
      id: 'o_mpr_5'
      cat: 'rel_eval'
      disabled: true
    orders_precision_5:
      name: 'Orders Precision@5'
      id: 'o_prec_5'
      cat: 'rel_eval'
      disabled: true
    orders_recall_5:
      name: 'Orders Recall@5'
      id: 'o_recall_5'
      cat: 'rel_eval'
      disabled: true
    'relevance conversion correlation':
      name: 'Rel Conv Correlation'
      id: 'conv_cor'
      cat: 'rel_eval'
    revenue:
      name: 'Revenue'
      id: 'revenue'
      cat: 'general'
    CAF:
      name: 'Clicks on First Item'
      id: 'clicks_f_item'
      disabled: true
      cat: 'user_eng'
    AR:
      name: 'Abandon Rate'
      id: 'aband_rate'
      disabled: true
      cat: 'user_eng'
    'count per session':
      name: 'Queries per Session'
      id: 'queries_session'
      disabled: true
      cat: 'user_eng'
    QDT:
      name: 'Query Dwell Time'
      id: 'dwell_time'
      disabled: true
      cat: 'user_eng'
    FCT:
      name: 'Earliest Item Click'
      id: 'first_click'
      disabled: true
      cat: 'user_eng'
    LCT:
      name: 'Latest Item Click'
      id: 'latest_click'
      disabled: true
      cat: 'user_eng'
    CPQ:
      name: 'Clicks Per Query'
      id: 'clicks_query'
      disabled: true
      cat: 'user_eng'
    MRR:
      name: 'Total Reciprocal Rank'
      id: 'mrr'
      disabled: true
      cat: 'user_eng'
    QRR:
      name: 'Query Reformulation Rate'
      id: 'qrr'
      disabled: true
      cat: 'user_eng'
    
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
      new_path = "search/drop_con_#{weeks}/page/overview"
      $(e.target).parents('.btn-group').find('.btn.btn.primary').removeClass(
        'btn-primary')
      $(e.target).addClass('btn-primary')
      @router.update_path(new_path, trigger: true)

    events['click .trending-periods button'] = (e) =>
      days = $(e.target).text()
      new_path = "search/trend_#{days}/page/overview"
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
          segment = that.router.path.search
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
    segment_cat = ''
    segment = @router.path.search
    segment_name = @segment_lookup[segment].name if segment?

    if segment? and (match = segment.match(/trend_(\d+)/))
      days = parseInt(match[1])
      periods =
        2: (days == 2 ? true: false)
        7: (days == 7 ? true: false)
        14: (days == 14 ? true: false)
        21: (days == 21 ? true: false)
        28: (days == 28 ? true: false)
      segment_cat = 'trending'
    else if segment? and (
      (match = segment.match(/poor_perform/)) or
      (match = segment.match(/drop_con_(\d+)/)))
      weeks = parseInt(match[1])
      periods =
        1: (weeks == 1 ? true: false)
        2: (weeks == 2 ? true: false)
        3: (weeks == 3 ? true: false)
        4: (weeks == 4 ? true: false)
      segment_cat = 'poor_performing'

    @$el.append( @navBar(
      periods: periods
      segment_name: segment_name
      segment: segment_cat) )

    metrics = @collection.toJSON()[0]
    overall_metrics =
      general:
        name: 'General'
        class: 'general'
        metrics: (metrics[m_db_id] for m_db_id, metric of @metrics_name \
          when metric.cat == 'general' and metrics[m_db_id]?)
      user_engage_metrics:
        name: 'User Engagement Metrics'
        class: 'user_eng'
        metrics: (metrics[m_db_id] for m_db_id, metric of @metrics_name \
          when metric.cat == 'user_eng' and metrics[m_db_id]?)
      correl_metrics:
        name: 'Relevance Evaluation Metrics'
        class: 'rel_eval'
        metrics: (metrics[m_db_id] for m_db_id, metric of @metrics_name \
          when metric.cat == 'rel_eval' and metrics[m_db_id]?)
          
    @$el.append(@summary_template(
      metrics: overall_metrics
      segment: segment
      view: this))

    $.each(@$el.find('.metric .mrow'), (i, div) ->
      max_height = 0
      $.each($(div).children(), (i, child) ->
        if $(child).height() > max_height
          max_height = $(child).height()
      )
      $.each($(div).children(), (i, child) ->
        $(child).height(max_height)
      )
    )


  unrender: =>
    @active = false

  navigate: (metric) =>
    query_segment = @router.path.search
    @router.update_path(
      "search/#{query_segment}/page/#{metric}", trigger: true)
