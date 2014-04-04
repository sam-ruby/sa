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
        @get_items() unless @active
      else
        @active = false
        @$el.children().not('.ajax-loader').not('ul.metrics').remove()
        @$el.find('ul.metrics').hide()
    )
    
  events: =>
    'click li.general-metrics a': (e)->
      @toggleTab(e)
      @show_general_metrics()
    'click li.user-engagement-metrics a': (e)->
      @toggleTab(e)
      @show_user_engagement_metrics()
    'click li.session-metrics a': (e)->
      @toggleTab(e)
      @show_session_metrics()
    'click tr.traffic a': (e) =>
      e.preventDefault()
      @navigate('traffic')
    'click tr.atc a': (e) =>
      e.preventDefault()
      @navigate('atc')
    'click tr.pvr a': (e) =>
      e.preventDefault()
      @navigate('pvr')
    'click tr.conversion a': (e) =>
      e.preventDefault()
      @navigate('conversion')
    'click tr.revenue a': (e) =>
      e.preventDefault()
      @navigate('revenue')
    'click tr.relevance_conversion_correlation a': (e) =>
      e.preventDefault()
      @navigate('conv_cor')

  get_items: (data) =>
    @active = true
    @$el.find('ul.metrics').css('display', 'block')
    @collection.get_items()

  prepare_for_render: =>
    @$el.find('.ajax-loader').css('display', 'inline-block')
   
  render: =>
    return unless @active
    @$el.find('.ajax-loader').hide()
    @show_general_metrics()
    @delegateEvents()
    this
    
  toggleTab: (e) =>
    e.preventDefault()
    @$el.find('li.active').removeClass('active')
    $(e.target).parent().addClass('active')

  show_general_metrics: =>
    @$el.children().not('.ajax-loader').not('ul.metrics').remove()
    metrics = @collection.toJSON()[0]
    general_metrics = [metrics.traffic, metrics.pvr, metrics.atc,
      metrics.conversion, metrics['relevance conversion correlation']]
    @$el.append(@summary_template(metrics: general_metrics))

  show_user_engagement_metrics: =>
    @$el.children().not('.ajax-loader').not('ul.metrics').remove()
    metrics = @collection.toJSON()[0]
    user_engage_metrics = [metrics['QDT'],  metrics['AR'], metrics['CPQ']]
    @$el.append(@summary_template(metrics: user_engage_metrics))

  show_session_metrics: =>
    @$el.children().not('.ajax-loader').not('ul.metrics').remove()
    metrics = @collection.toJSON()[0]
    session_metrics = [metrics.traffic, metrics.pvr, metrics.atc]
    @$el.append(@summary_template(metrics: session_metrics))

  unrender: =>
    @active = false

  navigate: (metric) =>
    @router.update_path("search/#{@router.task}/#{metric}", trigger: true)
