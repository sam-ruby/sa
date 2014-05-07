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
      if @router.date_changed or @router.cat_changed or !@active
        @get_items()
      path? and (@segment = path.search)
      if @segment == 'overview'
        @carousel.carousel(0)
        @carousel.carousel('pause')
      else if path.page? and path.page == 'overview'
        @carousel.carousel(1)
        @carousel.carousel('pause')
      else if path.details? and path.details == '1'
        @carousel.carousel(3)
        @carousel.carousel('pause')
      else if path.items? and path.details? and path.details == 'sig_comp'
        @carousel.carousel(4)
        @carousel.carousel('pause')
      else if path.page? and feature_paths.indexOf(path.page) != -1
        @carousel.carousel(2)
        @carousel.carousel('pause')
    )
 
  events: ->
    'click .score a': 'navigate'
    'click .segment-name a': 'navigate'
    'click .support-info': 'toggle_support_info'
    'click input.show-details': 'toggle_all_metric_info'

  toggle_all_metric_info: (e) ->
    if $(e.target).is(':checked')
      @$el.find('.overview-all .metric .mrow span.support-info').not(
        '.make-tiny').click()
    else
      @$el.find('.overview-all .metric .mrow span.support-info.make-tiny').click()


  toggle_support_info: (e) ->
    e.preventDefault()
    klasses = $(e.target).parents('div.mrow').attr('class').split(/\s+/)
    metric_class = (klass for klass in klasses when klass != 'mrow')
    if metric_class? and metric_class.length > 0
      metric_id = metric_class[0]
      support_rows = $(e.target).parents('div.metric').find(
        "div.mrow-support-info.#{metric_id}")
      if support_rows.length > 0
        if $(e.target).hasClass('make-tiny')
          support_rows.hide()
        else
          support_rows.show()
    $(e.target).toggleClass('make-tiny')

  get_items: (data) =>
    @active = true
    @$el.find('.ajax-loader').css('display', 'inline-block')
    @collection.get_items()

  prepare_for_render: =>
    @$el.find('.ajax-loader').css('display', 'inline-block')
   
  render: =>
    return unless @active
    @$el.find('.ajax-loader').hide()
    @$el.children().not('.ajax-loader').hide()
    
    @$el.append( @navBar(title: 'Metrics Overview') )
    
    metrics = @collection.toJSON()
    metric_segment = {}
    segments = {}
    segment_lookup = Searchad.Views.SearchTabs.IndexView.prototype.segment_lookup
    
    for segment_path, segment of segment_lookup
      if segment.id.match(/trend_(7|14|21|28)/i)
        continue
      else if segment.id.match(/drop_con/i)
        continue

      segments[segment.id] =
        name: segment.name
        path: segment_path

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
    correl_metrics = {}
    
    for metric_db_id, metric of metric_table when metric.cat == 'general'
      general_metrics[metric_db_id] = metric_segment[metric_db_id]

    for metric_db_id, metric of metric_table when metric.cat == 'user_eng'
      user_eng_metrics[metric_db_id] = metric_segment[metric_db_id]
    
    for metric_db_id, metric of metric_table when metric.cat == 'rel_eval'
      correl_metrics[metric_db_id] = metric_segment[metric_db_id]
    

    
    overall_metrics =
      general:
        name: 'General'
        class: 'general'
        metrics: general_metrics
      correl_metrics:
        name: 'Relevance Evaluation Metrics'
        class: 'rel_eval'
        metrics: correl_metrics
      user_engage_metrics:
        name: 'User Engagement Metrics'
        class: 'user_eng'
        metrics: user_eng_metrics

    @$el.append(@overall_template(
      metrics: overall_metrics
      metrics_name: Searchad.Views.SummaryMetrics.prototype.metrics_name
      segments: segments
      view: this))
      
  unrender: =>
    @active = false

  navigate: (e) =>
    e.preventDefault()
    link = $(e.target).attr('href')
    @router.update_path(link, trigger: true)
