Searchad.Views.MasterTab ||= {}

class Searchad.Views.MasterTab.IndexView extends Backbone.View
 initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('relevance:app', @init_relevance)
    @controller.bind('explore:app', @init_explore)

    @controller.bind('dashboard:index', @select_dashboard_tab)
    @controller.bind('poor-performing:index', @select_pp_tab)
    @controller.bind('search-rel:index', @select_sq_tab)
    @controller.bind('search-kpi:index', @select_search_kpi_tab)
    @controller.bind('do-search', @select_search_tab)
    @controller.bind('comp-analysis:index', @select_ca_tab)
    @widget_el =  $('div.modal')
    @widget_el.modal(
      backdrop: false
      show: false
      keyboard: true
    )
  
  events:
    'click .add-widget': 'openWidgetDialog'
    'click a.cancel-widget': 'cancelWidgetDialog'
    'click a.save-widget': 'saveWidget'
    'click li.search-quality-tab': 'searchQuality'
    'click li.poor-performing-tab': 'poorPerforming'
    'click li.search-kpi-tab': 'searchKPI'
    'click .dashboard-tab': 'dashBoard'
    'click button.btn': 'do_search'
    'click li.comp-analysis-tab': 'compAnalysis'
    
  get_tab_el: (data) ->
    css_classes = data.class.join(' ')
    tab =
      $("<li class='#{css_classes}'><a href='#{data.href}'>#{data.title}</a></li>")
  
  init_relevance: =>
    @clean_tabs()
    tabs = [{
      class: ['active', 'search-quality-tab']
      href: '#search_rel'
      title: 'Relevance'},
      {class: ['search-kpi-tab']
      href: '/#search_kpi'
      title: 'KPI'}]
    
    @$el.find('ul').prepend(@get_tab_el(tabs[1]))
    @$el.find('ul').prepend(@get_tab_el(tabs[0]))

  init_explore: =>
    @clean_tabs()
    tabs = [{
      class: ['active', 'poor-performing-tab']
      href: '#poor_performing'
      title: 'Poor Performing Intents'},
      {class: ['comp-analysis-tab']
      href: '/#comp_analysis'
      title: 'Competitive Analysis'}]
    
    @$el.find('ul').prepend(@get_tab_el(tabs[1]))
    @$el.find('ul').prepend(@get_tab_el(tabs[0]))


  toggleTab: (e) =>
    if $(e.target).hasClass('dashboard-tab')
      @$el.find('div.dashboard-tab').hide()
      @$el.find('div.add-widget').show()
    else
      @$el.find('div.dashboard-tab').show()
      @$el.find('div.add-widget').hide()
    
    @$el.find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')

  searchQuality: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('search-rel:index')
    @router.update_path('search_rel')

  searchKPI: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('search-kpi:index')
    @router.update_path('search_kpi')
  
  poorPerforming: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('poor-performing:index')
    @router.update_path('poor_performing')

  dashBoard: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('dashboard:index')
    @router.update_path('/')
  
  do_search: (e) =>
    e.preventDefault()
    query = $('form.form-search input.search-query').val()
    if query
      @router.update_path('search/query/' + query)
      @controller.trigger('content-cleanup')
      @controller.trigger('do-search', query: query)
  
  compAnalysis: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('comp-analysis:index')
    @router.update_path('comp_analysis')
  
  select_dashboard_tab: =>
    e = {}
    e.target = @$el.find('div.dashboard-tab').get(0)
    @toggleTab(e)

  select_pp_tab: =>
    e = {}
    e.target = @$el.find('li.poor-performing-tab a').get(0)
    @toggleTab(e)
 
  select_sq_tab: =>
    e = {}
    e.target = @$el.find('li.search-quality-tab a').get(0)
    @toggleTab(e)
   
  select_search_kpi_tab: =>
    e = {}
    e.target = @$el.find('li.search-kpi-tab a').get(0)
    @toggleTab(e)
  
  select_search_tab: =>
    e = {}
    e.target = @$el.find('li.search-tab a').get(0)
    @toggleTab(e)
 
  select_ca_tab: =>
    e = {}
    e.target = @$el.find('li.comp-analysis-tab a').get(0)
    @toggleTab(e)
 
  saveWidget: =>
    $('#main-content .modal', @el).modal('hide')
    # Trigger additional widgets from here.

  openWidgetDialog: =>
    @widget_el.modal('show')

  cancelWidgetDialog: =>
    @widget_el.modal('hide')

  clean_tabs: =>
    @$el.find('li').not('li.search-tab').remove()
