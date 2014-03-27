Searchad.Views.TopQuery ||= {}

class Searchad.Views.TopQuery extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @overview_template = JST["backbone/templates/overview"]
    
    @listenTo(@router, 'route', (route, params) =>
      @$el.children().not('.ajax-loader').remove() if @active
      if route == 'search' and @router.task == 'top'
        @$el.children().not('.ajax-loader').remove()
        @renderMetrics()
      else
        @active = false
    )
  
  active: false

  renderMetrics: =>
    data = [{
      name: 'NDCG'
      change: 1.23,
      queries: ['frozen', 'garcinia cambogia', 'bean bag chair', 'heater',
      'grill']},
      {name: 'Rev Relevance Correlation',
      change: -0.34,
      queries: ['frozen', 'garcinia cambogia', 'bean bag chair', 'heater',
      'grill']},
      {name: 'PVR',
      change: 5.34,
      queries: ['frozen', 'garcinia cambogia', 'bean bag chair', 'heater',
      'grill']},
      {name: 'ATC',
      change: 1.45,
      queries: ['frozen', 'garcinia cambogia', 'bean bag chair', 'heater',
      'grill']}]

    @$el.append(@overview_template(metrics: data))
    
  
