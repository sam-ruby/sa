Searchad.Views.MasterTab ||= {}

class Searchad.Views.MasterTab.IndexView extends Backbone.View
 initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    
    @controller.bind('poor-performing:index', @select_pp_tab)
    @controller.bind('search-rel:index', @select_sq_tab)
    @controller.bind('search-kpi:index', @select_search_kpi_tab)
    @controller.bind('query-monitoring-count:index', @select_qmc_tab)
    @controller.bind('query-monitoring-metrics:index', @select_qmm_tab)
    
    @controller.bind('master-tabs:cleanup', @unrender)
    @active = false


  events: =>
    #events on overview page
    'click li.search-quality-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('content-cleanup')
      @controller.trigger('search-rel:index')
      @router.update_path('search_rel')

    'click li.poor-performing-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('content-cleanup')
      @controller.trigger('poor-performing:index', trigger: true)
      @router.update_path('poor_performing')

    'click li.search-kpi-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('content-cleanup')
      @controller.trigger('search-kpi:index')
      @router.update_path('search_kpi')

    
  get_tab_el: (data) ->
    css_classes = data.class.join(' ')
    tab =
      $("<li class='#{css_classes}'><a href='#{data.href}'>#{data.title}</a></li>")
  
  init_overview: =>
    tabs = [{
      class: ['active', 'search-kpi-tab']
      href: '#search_kpi'
      title: 'KPI'},
      {class: ['search-quality-tab']
      href: '/#search_rel'
      title: 'Query Analysis'},
      {class: ['poor-performing-tab']
      href: '#poor_performing'
      title: 'Poor Performing Intents'}]
    @$el.prepend(@get_tab_el(tabs[2]))
    @$el.prepend(@get_tab_el(tabs[1]))
    @$el.prepend(@get_tab_el(tabs[0]))

  init_query_monitoring: =>
    tabs = [{
      class: ['query-monitoring-count-tab','active']
      href: '#query_monitoring/count'
      title: 'Query Count Analysis'},
     {
      class: ['query-monitoring-metrics-tab','active']
      href: '#query_monitoring/metrics'
      title: 'Query Metrics Analysis'}
    ]
    @$el.append(@get_tab_el(tabs[0]))
    @$el.append(@get_tab_el(tabs[1]))

  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    $(el).parents('li').addClass('active')

  select_pp_tab: =>
    unless @active
      @$el.css('display', 'block')
      @init_overview()
      @active = true
    @toggleTab(@$el.find('li.poor-performing-tab a'))
 
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
    @toggleTab(@$el.find('li.query-monitoring-count-tab a'))

  select_qmm_tab:=>
    unless @active
      @$el.css('display', 'block')
      @init_query_monitoring()
      @active = true
    @toggleTab(@$el.find('li.query-monitoring-metrics-tab a'))

  unrender: =>
    @$el.children().remove()
    @$el.hide()
    @active = false
