Searchad.Views.Search ||= {}
Searchad.Views.Search.SubTabs ||= {}

class Searchad.Views.Search.SubTabs.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
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
    @controller.trigger('search:walmart-items', query: @query)
  
  amazon_items: (e) =>
    e.preventDefault()
    @controller.trigger('sub-content-cleanup')
    @select_amazon_tab()
    @controller.trigger('search:amazon-items', query: @query)

  rev_rel: (e) =>
    e.preventDefault()
    @controller.trigger('sub-content-cleanup')
    @select_rev_rel_tab()
    @controller.trigger('search:rel-rev',
      query: @query
      id: @query_id
      query_items: @query_items
      top_rev_items: @top_rev_items
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

  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @hide_spin()

  render: (data) =>
    @query = data.query if data.query
    @query_id = data.id if data.id
    @query_items = data.query_items if data.query_items
    @top_rev_itemss = data.top_rev_items if data.top_rev_items
    if @active
      @select_stats_tab()
      return
    @$el.prepend(@template())
    @delegateEvents()
    @active = true

  show_spin: =>
    @$el.find('.ajax-loader').css('display', 'block')
  
  hide_spin: =>
    @$el.find('.ajax-loader').hide()
