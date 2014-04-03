#= require backbone/views/base
class Searchad.Views.SummaryMetrics extends Searchad.Views.Base
  initialize: (options) ->
    @collection = new Searchad.Collections.SummaryMetric()
    @listenTo(@collection, 'reset', @render)
    @listenTo(@collection, 'request', @prepare_for_render)
    super(options)
    
    @summary_template = JST["backbone/templates/overview"]
    
    @listenTo(@router, 'route', (route, params) =>
      @$el.children().not('.ajax-loader').remove() if @active
      if route == 'search'
        @get_items()
      else
        @active = false
    )
    @active = false
    
  events: =>
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
    @collection.get_items()

  prepare_for_render: =>
    @$el.find('.ajax-loader').css('display', 'inline-block')
   
  render: =>
    return unless @active
    @$el.find('.ajax-loader').hide()
    @$el.append( @summary_template(metrics: @collection.toJSON()[0]) )
    @delegateEvents()
    this
  
  unrender: =>
    @active = false

  navigate: (metric) =>
    @router.update_path("search/#{@router.task}/#{metric}", trigger: true)
