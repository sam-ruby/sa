#= require backbone/views/base
class Searchad.Views.SummaryMetrics extends Searchad.Views.Base
  initialize: (options) ->
    @collection = new Searchad.Collections.SummaryMetric()
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'request', @prepare_for_render)
    super(options)
    
    @summary_template = JST["backbone/templates/overview"]
    @navBar = JST["backbone/templates/summary_metrics"](title: 'Summary Metrics')
    
    @listenTo(@router, 'route', (route, params) =>
      if route == 'search'
        if @router.date_changed or @router.cat_changed or !@active or @router.query_segment_changed
          @get_items()
      else
        @active = false
        @$el.children().not('.ajax-loader').not('ul.metrics').remove()
        @$el.find('ul.metrics').hide()
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
    LCT:
      name: 'Latest Item Click'
      id: 'latest_click'
    QDT:
      name: 'Query Dwell Time'
      id: 'dwell_time'
    CPQ:
      name: 'Clicks Per Query'
      id: 'clicks_query'
    CAF:
      name: 'Clicks on First Item'
      id: 'clicks_f_item'
    AR:
      name: 'Abandon Rate'
      id: 'aband_rate'
    'count per session':
      name: 'Queries per Session'
      id: 'queries_session'
    
  events: =>
    events = {}
    that = this
    for metric, details of @metrics_name
      metric_id = details.id
      events["click tr.#{metric_id}"] = do (metric_id, that) ->
        (e) =>
          $(e.target).parents('table').find('tr.selected').removeClass(
            'selected')
          $(e.target).parents('tr').addClass('selected')
          e.preventDefault()
          that.navigate(metric_id)
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
    general_metrics = ['traffic', 'pvr', 'atc', 'conversion',
      'revenue' ]
    correl_metrics = ['relevance conversion correlation']
    user_engage_metrics = ['count per session', 'QDT', 'FCT', 'LCT', 'CPQ', 'CAF',
      'AR']

    overall_metrics =
      general:
        name: 'General'
        metrics: (metrics[m] for m in general_metrics)
      correl_metrics:
        name: 'Relevance Evaluation Metrics'
        metrics: (metrics[m] for m in correl_metrics)
      user_engage_metrics:
        name: 'User Engagement Metrics'
        metrics: (metrics[m] for m in user_engage_metrics)
    
    @$el.append(@summary_template(
      metrics: overall_metrics
      view: this))

  unrender: =>
    @active = false

  navigate: (metric) =>
    @router.update_path("search/#{@router.task}/#{metric}", trigger: true)
