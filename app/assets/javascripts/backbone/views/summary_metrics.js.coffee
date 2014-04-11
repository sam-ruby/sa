#= require backbone/views/base
class Searchad.Views.SummaryMetrics extends Searchad.Views.Base
  initialize: (options) ->
    @collection = new Searchad.Collections.SummaryMetric()
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'request', @prepare_for_render)
    super(options)
    
    @summary_template = JST["backbone/templates/overview"]
    @navBar = JST["backbone/templates/summary_metrics"](
      title: 'Metrics Overview')
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
      name: 'PVR'
      id: 'pvr'
    atc:
      name: 'ATC'
      id: 'atc'
    conversion:
      name: 'Conversion'
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
    
  events: =>
    events = {}
    events['click .info a'] = (e)=>
      metric = $(e.target).attr('class')
      icon = $(e.target).find('i')
      info = $(e.target).parents('.info')

      if icon.hasClass('icon-resize-horizontal')
        icon.removeClass('icon-resize-horizontal')
        icon.addClass('icon-resize-vertical')
        info.css('margin-bottom', '1em')
      else
        icon.removeClass('icon-resize-vertical')
        icon.addClass('icon-resize-horizontal')
        info.css('margin-bottom', '0')

      $(e.target).parents('div.overview').find(
        'div.metric.' + metric).toggle('slideup')

    that = this
    for metric, details of @metrics_name
      metric_id = details.id
      disabled = (details.disabled == true)
      events["click div.#{metric_id} .metric-name"] = do (
        metric_id, disabled, that) ->
        (e) =>
          e.preventDefault()
          return if disabled
          selected_row = $(e.target).parents('.overview').find(
            '.mrow.selected')
          if selected_row?
            selected_row.removeClass('selected')
            for col in selected_row.children()
              $(col).height('auto')

          max_height = 0
          for col in $(e.target).parents('.mrow').children()
            $(col).height() > max_height and (
              max_height = $(col).height())
          for col in $(e.target).parents('.mrow').children()
            $(col).height(max_height)
          $(e.target).parents('.mrow').addClass('selected')
          e.preventDefault()
          that.navigate(metric_id)
          
      events["click div.#{metric_id} .metric-queries"] = do (
        metric_id, disabled, that) ->
        (e) =>
          e.preventDefault()
          query = encodeURIComponent($(e.target).text())
          segment = that.segment
          feature = metric_id
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
    @$el.append(@navBar)

    metrics = @collection.toJSON()[0]
    general_metrics = ['traffic', 'conversion', 'pvr', 'atc', 'revenue' ]
    correl_metrics = ['relevance conversion correlation']
    user_engage_metrics = ['CAF', 'AR', 'count per session', 'QDT', 'FCT',
      'LCT', 'CPQ']

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
      view: this))

  unrender: =>
    @active = false

  navigate: (metric) =>
    query_segment = @router.path.search
    @router.path.page = metric
    @router.update_path(
      "search/#{query_segment}/page/#{metric}", trigger: true)
