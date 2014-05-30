Searchad.Views.MasterTab ||= {}

class Searchad.Views.MasterTab.IndexView extends Backbone.View
 initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @active = false
    @performance_sub_tabs  = _.template('<ul class="nav nav-tabs">' +
      '<li class="active poor-performing">' +
      '<a href="#search/performance/poor_performing">' +
      'Poor Performing in 30 Days</a></li>' +
      '<li class="trending">' +
      '<a href="#search/performance/trending">Trending</a></li>' +
      '</ul>')
    
    @listenTo(@router, 'route', (route, params) =>
      if params?
        task = params[0]
        sub_task = params[1]

      if route != 'search'
        @unrender()
      else if task != 'performance'
        @unrender()
      else if sub_task == 'poor_performing'
        @search_poor_performing()
      else if sub_task == 'trending'
        @search_trending()
    )

  search_poor_performing: ->
    unless @active
      @$el.append( @performance_sub_tabs() )
      @delegateEvents()
      @active = true
    @$el.find('li.active').removeClass('active')
    @$el.find('li.poor-performing').addClass('active')

  search_trending: ->
    unless @active
      @$el.append( @performance_sub_tabs() )
      @delegateEvents()
      @active = true
    @$el.find('li.active').removeClass('active')
    @$el.find('li.trending').addClass('active')

  init_query_monitoring: =>
    tabs = [{
      class: ['qm-count-top-tab','active']
      href: '#query_monitoring/count'
      title: 'Query Count'},
     {
      class: ['qm-metrics-top-tab']
      href: '#query_monitoring/metrics'
      title: 'Query Metrics'}
    ]
    @$el.append(@get_tab_el(tabs[0]))
    @$el.append(@get_tab_el(tabs[1]))

  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    $(el).parents('li').addClass('active')

  select_trending_tab: =>
    unless @active
      @init_overview()
      @active = true
    @toggleTab(@$el.find('li.trending-tab a'))
 
  select_sq_tab: =>
    unless @active
      @$el.css('display', 'block')
      @init_overview()
      @active = true
    @toggleTab(@$el.find('li.search-quality-tab a'))

  select_search_kpi_tab: =>
    unless @active
      @$el.css('display', 'block')
      @init_overview()
      @active = true
    @toggleTab(@$el.find('li.search-kpi-tab a'))

  select_qmc_tab:=>
    unless @active
      @$el.css('display', 'block')
      @init_query_monitoring()
      @active = true
    @toggleTab(@$el.find('li.qm-count-top-tab a'))

  select_qm_metrics_tab:=>
    unless @active
      @$el.css('display', 'block')
      @init_query_monitoring()
      @active = true
    @toggleTab(@$el.find('li.qm-metrics-top-tab a'))

  unrender: =>
    @$el.children().remove()
    @active = false
