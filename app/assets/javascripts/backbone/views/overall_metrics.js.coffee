#= require backbone/views/base
#= require backbone/views/summary_metrics

class Searchad.Views.OverallMetrics extends Searchad.Views.Base
  initialize: (options) ->
    @collection = new Searchad.Collections.OverallMetric()
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'request', @prepare_for_render)
    super(options)
    
    @overall_template = JST["backbone/templates/overall_segments"]
    @navBar = JST["backbone/templates/overall_segments_navbar"]
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
      else if path? and path.page? and path.page == 'overview'
        @carousel.carousel(1)
        @carousel.carousel('pause')
      else if path? and path.details? and path.details == '1'
        @carousel.carousel(3)
        @carousel.carousel('pause')
      else if path? and path.page? and feature_paths.indexOf(path.page) != -1
        @carousel.carousel(2)
        @carousel.carousel('pause')
    )
 
  events: ->
    'click .score.o-content.a': 'navigate'

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
    
    @$el.append( @navBar() )
    
    general_metric_names = ['traffic', 'conversion', 'OOS', 'pvr', 'atc', 'revenue' ]
    correl_metric_names = ['relevance conversion correlation']
    user_engage_metric_names = ['CAF', 'AR', 'count per session', 'QDT', 'FCT',
      'LCT', 'CPQ', 'MRR']
    
    metrics = @collection.toJSON()
    general_metrics = {}
    user_eng_metrics = {}
    correl_metrics = {}
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

      for  metric in metrics
        if general_metric_names.indexOf(metric.metrics_name) != -1
          if !general_metrics[metric.metrics_name]?
            general_metrics[metric.metrics_name] = {}
          if segment.id == metric.segmentation
            general_metrics[metric.metrics_name][segment.id] = metric
          
        else if correl_metric_names.indexOf(metric.metrics_name) != -1
          if !correl_metrics[metric.metrics_name]?
            correl_metrics[metric.metrics_name] = {}
          if segment.id == metric.segmentation
            correl_metrics[metric.metrics_name][segment.id] = metric
        
        else if user_engage_metric_names.indexOf(metric.metrics_name) != -1
          if !user_eng_metrics[metric.metrics_name]?
            user_eng_metrics[metric.metrics_name] = {}
          if segment.id == metric.segmentation
            user_eng_metrics[metric.metrics_name][segment.id] = metric
    
    overall_metrics =
      general:
        name: 'General'
        class: 'general'
        metrics: general_metrics
      user_engage_metrics:
        name: 'User Engagement Metrics'
        class: 'user_eng'
        metrics: user_eng_metrics
      correl_metrics:
        name: 'Relevance Evaluation Metrics'
        class: 'rel_eval'
        metrics: correl_metrics

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
