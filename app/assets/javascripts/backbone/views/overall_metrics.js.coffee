#= require backbone/views/base
#= require backbone/views/summary_metrics

class Searchad.Views.OverallMetrics extends Searchad.Views.Base
  initialize: (options) ->
    @collection = new Searchad.Collections.OverallMetric()
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'request', @prepare_for_render)
    super(options)
    
    @overall_template = JST["backbone/templates/overall_segments"]
    @navBar = JST["backbone/templates/mini_navbar"]
    @carousel = @$el.parents('.carousel.slide')
    feature_paths = (
      metric.id for metric_id, metric of Searchad.Views.SummaryMetrics.prototype.metrics_name)
    @listenTo(@router, 'route:search', (path, filter) =>
      view = this
      if @router.date_changed or @router.cat_changed or @router.search_inited
        @dirty = true
      path? and (@segment = path.search)
      if @segment == 'overview'
        @get_items() if @dirty
        @controller.set_flight_status(true)
        @carousel.carousel(0).queue(->
          view.controller.set_flight_status(false))
        @carousel.carousel('pause')
      else if path.page? and path.page == 'overview'
        @controller.set_flight_status(true)
        @carousel.carousel(1).queue(->
          view.controller.set_flight_status(false))
        @carousel.carousel('pause')
      else if path.details? and path.details == '1'
        @controller.set_flight_status(true)
        @carousel.carousel(3).queue(->
          view.controller.set_flight_status(false))
        @carousel.carousel('pause')
      else if path.details? and path.details == 'sig_comp'
        @controller.set_flight_status(true)
        @carousel.carousel(4).queue(->
          view.controller.set_flight_status(false))
        @carousel.carousel('pause')
      else if @segment == 'adhoc' and path.query?
        @controller.set_flight_status(true)
        @carousel.carousel(3).queue(->
          view.controller.set_flight_status(false))
        @carousel.carousel('pause')
      else if path.page? and feature_paths.indexOf(path.page) != -1
        @controller.set_flight_status(true)
        @carousel.carousel(2).queue(->
          view.controller.set_flight_status(false))
        @carousel.carousel('pause')
    )
 
  events: ->
    'click .score a': 'navigate'
    'click .segment-name a': 'navigate'
    'click .metric div.name': 'toggle_support_info'
    'click input.show-details': 'toggle_all_metric_info'

  toggle_all_metric_info: (e) ->
    if $(e.target).is(':checked')
      @$el.find('.overview-all .metric .mrow .name').not(
        '.make-tiny').click()
    else
      @$el.find('.overview-all .metric .mrow .name.make-tiny').click()


  toggle_support_info: (e) ->
    klasses = $(e.target).parents('div.mrow').attr('class').split(/\s+/)
    metric_class = (klass for klass in klasses when klass != 'mrow')
    if metric_class? and metric_class.length > 0
      metric_id = metric_class[0]
      support_rows = $(e.target).parents('div.metric').find(
        "div.mrow-support-info.#{metric_id}")
      if support_rows.length > 0
        support_rows.toggle('slideup')
    $(e.target).toggleClass('make-tiny')

  get_items: (data) =>
    @$el.find('.ajax-loader').css('display', 'inline-block')
    @collection.get_items()

  prepare_for_render: =>
    @$el.find('.ajax-loader').css('display', 'block')
   
  render: =>
    @$el.children().not('.ajax-loader').remove()
    @$el.append( @navBar(title: 'Metrics Overview') )
  
    if @collection.toJSON().length > 0
      metrics = @collection.toJSON()[0].metrics
      segment_metadata = @collection.toJSON()[0].segment_metadata
    else
      metrics = []
      segment_metadata = []

    metric_segment = {}
    segments = {}
    segment_lookup = Searchad.Views.SearchTabs.IndexView.prototype.segment_lookup
    
    for segment_path, segment of segment_lookup
      if segment.id.match(/trend_(2|14|21|28)/i)
        continue
      else if segment.id.match(/drop_con/i)
        continue
      per_seg_meta_data = (seg_data for seg_data in segment_metadata when seg_data.segmentation == segment.id)

      segments[segment.id] =
        name: segment.name
        path: segment_path

      if per_seg_meta_data.length > 0
        segments[segment.id].traffic = per_seg_meta_data[0].traffic_percent
        segments[segment.id].revenue = per_seg_meta_data[0].revenue_percent
        segments[segment.id].queries = per_seg_meta_data[0].seg_query_count

      for  metric in metrics when metric.segmentation == segment.id
        metric_segment[metric.metrics_name] = {} unless metric_segment[metric.metrics_name]?
        metric_segment[metric.metrics_name][segment.id] = metric

    mark_score = (metric, comp) ->
      score = null
      for segment_id, metric_details of metric
        score = metric_details.value unless score?
        if comp == 'min'
          if metric_details.value < score
            score = metric_details.value
        else if comp == 'max'
          if metric_details.value > score
            score = metric_details.value

      if score
        for segment_id, metric_details of metric when metric_details.value == score
          metric_details.worst = true
          break

    metric_table = Searchad.Views.SummaryMetrics.prototype.metrics_name
    for metric_db_id, m_details of metric_segment
      m_obj = metric_table[metric_db_id]
      mark_score(metric_segment[metric_db_id], m_obj.mark_worst) if \
        m_obj and m_obj.mark_worst?
    
    general_metrics = {}
    user_eng_metrics = {}
    rel_orders = {}
    rel_eval = {}
    
    for metric_db_id, metric of metric_table when metric.cat == 'general'
      general_metrics[metric_db_id] = metric_segment[metric_db_id]

    for metric_db_id, metric of metric_table when metric.cat == 'user_eng'
      user_eng_metrics[metric_db_id] = metric_segment[metric_db_id]
    
    for metric_db_id, metric of metric_table when metric.cat == 'rel_orders'
      rel_orders[metric_db_id] = metric_segment[metric_db_id]
    
    for metric_db_id, metric of metric_table when metric.cat == 'rel_eval'
      rel_eval[metric_db_id] = metric_segment[metric_db_id]
    
    overall_metrics =
      general:
        name: 'General Metrics'
        class: 'general'
        metrics: general_metrics
      rel_orders:
        name: 'Relevance Metrics based on Orders'
        class: 'rel_orders'
        metrics: rel_orders
      rel_eval:
        name: 'Relevance Metrics based on Evaluation'
        class: 'rel_eval'
        metrics: rel_eval
      user_engage_metrics:
        name: 'User Engagement Metrics'
        class: 'user_eng'
        metrics: user_eng_metrics

    div_container = @overall_template(
      metrics: overall_metrics
      metrics_name: Searchad.Views.SummaryMetrics.prototype.metrics_name
      segments: segments
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

    @dirty = false
    this
      
  navigate: (e) =>
    e.preventDefault()
    link = $(e.target).attr('href')
    @router.update_path(link, trigger: true)
