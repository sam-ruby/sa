#= require backbone/views/base
class Searchad.Views.SummaryMetrics extends Searchad.Views.Base
  initialize: (options) ->
    @collection = new Searchad.Collections.SummaryMetric()
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'request', @prepare_for_render)
    super(options)
    
    @summary_template = JST["backbone/templates/overview"]
    
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
    events =
      'click li.general-metrics a': (e)->
        @toggleTab(e)
        @show_general_metrics()
      'click li.user-engagement-metrics a': (e)->
        @toggleTab(e)
        @show_user_engagement_metrics()
      'click li.rel-eval-metrics a': (e)->
        @toggleTab(e)
        @show_rel_eval_metrics()
      'click li.session-metrics a': (e)->
        @toggleTab(e)
        @show_session_metrics()

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
    @$el.find('ul li.active a').trigger('click')
    this
    
  toggleTab: (e) =>
    e.preventDefault()
    @$el.find('li.active').removeClass('active')
    $(e.target).parent().addClass('active')

  show_rel_eval_metrics: =>
    @$el.children().not('.ajax-loader').not('ul.metrics').remove()
    metrics = @collection.toJSON()[0]
    general_metrics = [metrics['relevance conversion correlation']]
    @$el.append(@summary_template(
      metrics: general_metrics
      view: this))
    @$el.find('table tr:nth-child(2)').trigger('click')
  
  show_general_metrics: =>
    @$el.children().not('.ajax-loader').not('ul.metrics').remove()
    @$el.find('.ajax-loader').hide()
    metrics = @collection.toJSON()[0]
    general_metrics = [metrics.traffic, metrics.pvr, metrics.atc,
      metrics.conversion, metrics.revenue]
    @$el.append(@summary_template(
      metrics: general_metrics
      view: this))
    @$el.find('table tr:nth-child(2)').trigger('click')
  
  show_user_engagement_metrics: =>
    @$el.children().not('.ajax-loader').not('ul.metrics').remove()
    metrics = @collection.toJSON()[0]
    user_engage_metrics = [metrics['count per session'], metrics['QDT'], metrics['FCT'], metrics['LCT'], metrics['CPQ'],metrics['CAF'], metrics['AR']]
    @$el.append(@summary_template(
      metrics: user_engage_metrics
      view: this))
    @$el.find('table tr:nth-child(2)').trigger('click')

  show_session_metrics: =>
    @$el.children().not('.ajax-loader').not('ul.metrics').remove()
    metrics = @collection.toJSON()[0]
    session_metrics = [metrics.traffic, metrics.pvr, metrics.atc]
    @$el.append(@summary_template(
      metrics: session_metrics
      view: this))
    @$el.find('table tr:nth-child(2)').trigger('click')

  unrender: =>
    @active = false

  navigate: (metric) =>
    @router.update_path("search/#{@router.task}/#{metric}", trigger: true)
