Searchad.Views.Search ||= {}
Searchad.Views.Search.SubTabs ||= {}

class Searchad.Views.Search.SubTabs.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('search:sub-tab-cleanup', @unrender)
    @controller.bind('search:sub-content:show-spin', @show_spin)
    @controller.bind('search:sub-content:hide-spin', @hide_spin)
    @active = false
  
  data:
    query: null


  events:
    'click li.search-stats-tab': 'stats'
    'click li.search-amazon-items-tab': 'amazon_items'
    'click li.search-walmart-items-tab': 'walmart_items'
    'click li.rev-rel-tab': 'rev_rel'
    'click li.cvr-dropped-item-comparison-tab': 'show_cvr_dropped_item_comparison' # .cvr-dropped-item-comparison

  template: JST['backbone/templates/poor_performing/search_sub_tabs']

  update_url: (path) =>
    if @data.query
      newPath = Utils.UpdateURLParam(window.location.hash, 'query',
        @data.query)
      @router.navigate(path + newPath)

  toggleTab: (e) =>
    @$el.find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')

  stats: (e) =>
    e.preventDefault()
    @controller.trigger('sub-content-cleanup')
    @select_stats_tab()
    @controller.trigger('search:stats', query: @query)
  
  walmart_items: (e) =>
    e.preventDefault()
    @controller.trigger('sub-content-cleanup')
    @select_walmart_tab()
    @controller.trigger('search:walmart-items',
      query: @query
      view: @view)
  
  amazon_items: (e) =>
    e.preventDefault()
    @controller.trigger('sub-content-cleanup')
    @select_amazon_tab()
    @controller.trigger('search:amazon-items',
      query: @query
      view: @view)

  rev_rel: (e) =>
    e.preventDefault()
    @controller.trigger('sub-content-cleanup')
    @select_rev_rel_tab()
    @controller.trigger('search:rel-rev',
      query: @query
      view: @view)

  show_cvr_dropped_item_comparison:(e)=>
    e.preventDefault()
    @controller.trigger('sub-content-cleanup')
    @select_cvr_dropped_item_comparison_tab()
    console.log("show_cvr_dropped_item_comparison")
    @controller.trigger('cvr_dropped_query:item_comparison',
      query: @data.query
      query_date: @data.query_date
      weeks_apart: @data.weeks_apart
    )
  
  select_stats_tab: () =>
    e = {}
    e.target = @$el.find('li.search-stats-tab a').get(0)
    @toggleTab(e)

  select_walmart_tab: () =>
    e = {}
    e.target = @$el.find('li.search-walmart-items-tab a').get(0)
    @toggleTab(e)
  
  select_amazon_tab: () =>
    e = {}
    e.target = @$el.find('li.search-amazon-items-tab a').get(0)
    @toggleTab(e)
    
  select_rev_rel_tab: () =>
    e = {}
    e.target = @$el.find('li.rev-rel-tab a').get(0)
    @toggleTab(e)

  select_cvr_dropped_item_comparison_tab:()=>
    e = {}
    e.target = @$el.find('li.cvr-dropped-item-comparison-tab a').get(0)
    @toggleTab(e)

  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @hide_spin()

  render: (data) =>
    console.log("data", data);
    @query = data.query if data.query
    @view = data.view if data.view
    @data = data;
    @$el.prepend(@template()) unless @active
    @delegateEvents()   
    if data.tab == 'rel-rev-analysis'
      @$el.find('li.rev-rel-tab').first().trigger('click')
    else if data.tab == 'amazon'
      @$el.find('li.search-amazon-items-tab').first().trigger('click')
    else if data.tab =='cvr-dropped-item-comparison'
      @$el.find('li.cvr-dropped-item-comparison-tab').first().trigger('click')
    else
      @$el.find('li.search-stats-tab').first().trigger('click')
    @active = true

  show_spin: =>
    @$el.find('.ajax-loader').css('display', 'block')
  
  hide_spin: =>
    @$el.find('.ajax-loader').hide()
