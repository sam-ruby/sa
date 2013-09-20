Searchad.Views.MasterTab ||= {}

class Searchad.Views.MasterTab.IndexView extends Backbone.View
 initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('relevance:app', @init_relevance)
    @controller.bind('explore:app', @init_explore)
    @controller.bind('query-perf-comp:app', @init_query_perf_comp)

    @controller.bind('poor-performing:index', @select_pp_tab)
    @controller.bind('search-rel:index', @select_sq_tab)
    @controller.bind('search-kpi:index', @select_search_kpi_tab)
    @controller.bind('do-search', @select_search_tab)
    @controller.bind('comp-analysis:index', @select_ca_tab)
    @controller.bind('query-comparison', @select_query_comp_tab)

  events:
    'click .add-widget': 'openWidgetDialog'
    'click a.cancel-widget': 'cancelWidgetDialog'
    'click a.save-widget': 'saveWidget'
    'click li.search-quality-tab': 'searchQuality'
    'click li.poor-performing-tab': 'poorPerforming'
    'click li.search-kpi-tab': 'searchKPI'
    'click button.search-btn': 'do_search'
    'click li.comp-analysis-tab': 'compAnalysis'
    'click li.query-comparison-details-tab': 'queryComparison'
    
  get_tab_el: (data) ->
    css_classes = data.class.join(' ')
    tab =
      $("<li class='#{css_classes}'><a href='#{data.href}'>#{data.title}</a></li>")
  
  init_relevance: =>
    @clean_tabs()
    tabs = [{
      class: ['active', 'search-kpi-tab']
      href: '#search_kpi'
      title: 'KPI'},
      {class: ['poor-performing-tab']
      href: '#poor_performing'
      title: 'Poor Performing Intents'},
      {class: ['search-quality-tab']
      href: '/#search_rel'
      title: 'Relevance Revenue Rank Comparison'}]
    
    @$el.find('ul').prepend(@get_tab_el(tabs[2]))
    @$el.find('ul').prepend(@get_tab_el(tabs[1]))
    @$el.find('ul').prepend(@get_tab_el(tabs[0]))

  init_explore: =>
    @clean_tabs()
    tabs = [{
      class: ['comp-analysis-tab']
      href: '/#comp_analysis'
      title: 'Amazon Relevance Comparison'}]
    @$el.find('ul').prepend(@get_tab_el(tabs[0]))

  init_query_perf_comp: =>
    @clean_tabs()
    tabs = [{
      class: ['query-comparison-details-tab']
      href: '/#query_perf_comparison'
      title: 'Details'}]
    @$el.find('ul').prepend(@get_tab_el(tabs[0]))

  toggleTab: (e) =>
    @$el.find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')

  queryComparison: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('query-comparison')
    @router.update_path('query_perf_comparison')


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
    @controller.trigger('poor-performing:index', trigger: true)

  do_search: (e) =>
    e.preventDefault()
    query = $('form.form-search input.search-query').val()
    query_parts = query.match(/([^:]+):?(date)?:?(.*)/) if query
    return unless query
    data = {}
  
    if query_parts and query_parts[2] != undefined
      data.query = query_parts[1]
      data.search_date = query_parts[3]
      event = 'do-search-with-comparison'
    else
      data.query = query
      event = 'do-search'
    
    @router.update_path('search/query/' + encodeURIComponent(data.query))
    @controller.trigger('content-cleanup')
    @controller.trigger(event, data)

  compAnalysis: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('comp-analysis:index')
    @router.update_path('comp_analysis')
  
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
 
 select_query_comp_tab: =>
    e = {}
    e.target = @$el.find('li.query-comparison-details-tab a').get(0)
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


