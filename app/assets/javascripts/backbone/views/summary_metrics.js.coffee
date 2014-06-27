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
      if @router.date_changed or @router.cat_changed or @router.query_segment_changed
        @dirty = true
      if path? and path.page? and path.page.match(/overview/i)
        @get_items()if @dirty
    )
  
  metrics_name:
    traffic:
      name: 'Traffic'
      id: 'traffic'
      cat: 'general'
      unit: 'query'
    conversion:
      name: 'Conversion Rate'
      id: 'conversion'
      cat: 'general'
      unit: 'percentage'
      mark_worst: 'min'
    pvr:
      name: 'Product View Rate'
      id: 'pvr'
      cat: 'general'
      unit: 'percentage'
      mark_worst: 'min'
    atc:
      name: 'Add To Cart Rate'
      id: 'atc'
      cat: 'general'
      unit: 'percentage'
      mark_worst: 'min'
    OOS:
      name: 'Out of Stock Rate'
      id: 'oos'
      cat: 'general'
      unit: 'percentage'
      mark_worst: 'max'
    P1_OOS:
      name: 'Page 1 OOS Rate'
      id: 'p1_oos'
      cat: 'general'
      unit: 'percentage'
      mark_worst: 'max'
    revenue:
      name: 'Revenue'
      id: 'revenue'
      cat: 'general'
      unit: 'dollar'
    # Order based
    orders_ndcg_5:
      name: 'Orders NDCG@5'
      id: 'o_ndcg_5'
      cat: 'rel_orders'
      unit: 'score'
      mark_worst: 'min'
    orders_ndcg_1:
      name: 'Orders NDCG@1'
      id: 'o_ndcg_1'
      cat: 'rel_orders'
      unit: 'score'
      mark_worst: 'min'
    orders_ndcg_16:
      name: 'Orders NDCG@16'
      id: 'o_ndcg_16'
      cat: 'rel_orders'
      unit: 'score'
      mark_worst: 'min'
    ###
    orders_mpr_5:
      name: 'Orders MPR@5'
      id: 'o_mpr_5'
      cat: 'rel_orders'
      unit: 'score'
      mark_worst: 'min'
    orders_mpr_1:
      name: 'Orders MPR@1'
      id: 'o_mpr_1'
      cat: 'rel_orders'
      unit: 'score'
      mark_worst: 'min'
    orders_mpr_16:
      name: 'Orders MPR@16'
      id: 'o_mpr_16'
      cat: 'rel_orders'
      unit: 'score'
      mark_worst: 'min'
    ###
    orders_precision_5:
      name: 'Orders Prec@5'
      id: 'o_prec_5'
      cat: 'rel_orders'
      unit: 'score'
      mark_worst: 'min'
    orders_precision_1:
      name: 'Orders Prec@1'
      id: 'o_prec_1'
      cat: 'rel_orders'
      unit: 'score'
      mark_worst: 'min'
    orders_precision_16:
      name: 'Orders Prec@16'
      id: 'o_prec_16'
      cat: 'rel_orders'
      unit: 'score'
      mark_worst: 'min'
    orders_recall_5:
      name: 'Orders Recall@5'
      id: 'o_recall_5'
      cat: 'rel_orders'
      unit: 'score'
      mark_worst: 'min'
    orders_recall_1:
      name: 'Orders Recall@1'
      id: 'o_recall_1'
      cat: 'rel_orders'
      unit: 'score'
      mark_worst: 'min'
    orders_recall_16:
      name: 'Orders Recall@16'
      id: 'o_recall_16'
      cat: 'rel_orders'
      unit: 'score'
      mark_worst: 'min'
    # Eval based
    eval_ndcg_5:
      name: 'Evals NDCG@5'
      id: 'e_ndcg_5'
      cat: 'rel_eval'
      unit: 'score'
      mark_worst: 'min'
      disabled: false
    eval_ndcg_1:
      name: 'Eval NDCG@1'
      id: 'e_ndcg_1'
      cat: 'rel_eval'
      unit: 'score'
      mark_worst: 'min'
      disabled: false
    eval_ndcg_16:
      name: 'Eval NDCG@16'
      id: 'e_ndcg_16'
      cat: 'rel_eval'
      unit: 'score'
      mark_worst: 'min'
      disabled: false
    ###
    eval_mpr_5:
      name: 'Eval MPR@5'
      id: 'e_mpr_5'
      cat: 'rel_eval'
      unit: 'score'
      mark_worst: 'min'
      disabled: true
    eval_mpr_1:
      name: 'Eval MPR@1'
      id: 'e_mpr_1'
      cat: 'rel_eval'
      unit: 'score'
      mark_worst: 'min'
      disabled: true
    eval_mpr_16:
      name: 'Eval MPR@16'
      id: 'e_mpr_16'
      cat: 'rel_eval'
      unit: 'score'
      mark_worst: 'min'
      disabled: true
    ###
    eval_precision_5:
      name: 'Eval Prec@5'
      id: 'e_prec_5'
      cat: 'rel_eval'
      unit: 'score'
      mark_worst: 'min'
      disabled: false
    eval_precision_1:
      name: 'Eval Prec@1'
      id: 'e_prec_1'
      cat: 'rel_eval'
      unit: 'score'
      mark_worst: 'min'
      disabled: false
    eval_precision_16:
      name: 'Eval Prec@16'
      id: 'e_prec_16'
      cat: 'rel_eval'
      unit: 'score'
      mark_worst: 'min'
      disabled: false
    eval_recall_5:
      name: 'Eval Recall@5'
      id: 'e_recall_5'
      cat: 'rel_eval'
      unit: 'score'
      mark_worst: 'min'
      disabled: false
    eval_recall_1:
      name: 'Eval Recall@1'
      id: 'e_recall_1'
      cat: 'rel_eval'
      unit: 'score'
      mark_worst: 'min'
      disabled: false
    eval_recall_16:
      name: 'Eval Recall@16'
      id: 'e_recall_16'
      cat: 'rel_eval'
      unit: 'score'
      mark_worst: 'min'
      disabled: false
    CAF:
      name: 'First Item Clicks'
      id: 'clicks_f_item'
      cat: 'user_eng'
      unit: 'percentage'
      mark_worst: 'min'
    AR:
      name: 'Abandon Rate'
      id: 'aband_rate'
      cat: 'user_eng'
      unit: 'percentage'
      mark_worst: 'max'
    'count per session':
      name: 'Queries per Sess'
      id: 'queries_session'
      disabled: true
      cat: 'user_eng'
      unit: 'query'
      decimals: 4
    QDT:
      name: 'Query Dwell Time'
      id: 'dwell_time'
      cat: 'user_eng'
      unit: 'seconds'
      mark_worst: 'min'
    FCT:
      name: 'Earliest Item Click'
      id: 'first_click'
      cat: 'user_eng'
      unit: 'seconds'
      mark_worst: 'max'
    LCT:
      name: 'Latest Item Click'
      id: 'latest_click'
      cat: 'user_eng'
      unit: 'seconds'
      mark_worst: 'max'
    CPQ:
      name: 'Clicks Per Query'
      id: 'clicks_query'
      cat: 'user_eng'
      unit: 'click'
      mark_worst: 'min'
    MRR:
      name: 'Tot Reciprocal Rank'
      id: 'mrr'
      cat: 'user_eng'
      unit: 'score'
      mark_worst: 'min'
    QRR:
      name: 'Query Reformulation'
      id: 'qrr'
      cat: 'user_eng'
      unit: 'percentage'
      mark_worst: 'max'
    
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
          
      events["click div.#{metric_id} .metric-queries a"] = do (
        metric_id, disabled, that) ->
        (e) =>
          e.preventDefault()
          return if disabled
          $(e.target).parents('.overview').find(
            '.mrow.selected').removeClass('selected')
          $(e.target).parents('.mrow').addClass('selected')
          
          query = encodeURIComponent($(e.target).attr('href'))
          segment = that.router.path.search
          feature = metric_id
          if query.match(/more[\.]{3}/)
            that.router.update_path(
              "search/#{segment}/page/#{feature}", trigger: true)
          else
            that.router.update_path(
              "search/#{segment}/page/#{feature}/details/1/query/#{query}",
              trigger: true)

    events

  get_items: (data) =>
    @$el.find('ul.metrics').css('display', 'block')
    @collection.get_items()

  prepare_for_render: =>
    @$el.find('.ajax-loader').css('display', 'block')
   
  render: =>
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
    for m_db_id, metric of metrics when metric.queries? and metric.queries.length > 76
      metric.orig_queries = metric.queries
      while metric.queries.length > 76
        qs = metric.queries.split(',')
        if qs.length == 1
          metric.queries = metric.queries.substr(0, 75)
        else
          metric.queries = qs.splice(0, qs.length-1).join(',')

    overall_metrics =
      general:
        name: 'General Metrics'
        class: 'general'
        metrics: (metrics[m_db_id] for m_db_id, metric of @metrics_name \
          when metric.cat == 'general' and metrics[m_db_id]?)
      rel_orders:
        name: 'Relevance Metrics based on Orders'
        class: 'rel_orders'
        metrics: (metrics[m_db_id] for m_db_id, metric of @metrics_name \
          when metric.cat == 'rel_orders' and metrics[m_db_id]?)
      rel_eval:
        name: 'Relevance Metrics based on Evaluation'
        class: 'rel_eval'
        metrics: (metrics[m_db_id] for m_db_id, metric of @metrics_name \
          when metric.cat == 'rel_eval' and metrics[m_db_id]?)
      user_engage_metrics:
        name: 'User Engagement Metrics'
        class: 'user_eng'
        metrics: (metrics[m_db_id] for m_db_id, metric of @metrics_name \
          when metric.cat == 'user_eng' and metrics[m_db_id]?)
    
    div_container = @summary_template(
      metrics: overall_metrics
      segment: segment
      view: this)

    if @controller.get_flight_status() == true
      that = this
      setTimeout(() ->
        that.$el.find('.ajax-loader').hide()
        that.$el.append(div_container)
      ,500)
    else
      @$el.find('.ajax-loader').hide()
      @$el.append(div_container)

    $.each($(div_container).find('.metric .mrow'), (i, div) ->
      max_height = 0
      $.each($(div).children(), (i, child) ->
        if $(child).height() > max_height
          max_height = $(child).height()
      )
      $.each($(div).children(), (i, child) ->
        $(child).height(max_height)
      )
    )
    @dirty = false
    this

  navigate: (metric) =>
    query_segment = @router.path.search
    @router.update_path(
      "search/#{query_segment}/page/#{metric}", trigger: true)
