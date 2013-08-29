Searchad.Views.Search.SubTabs ||= {}

class Searchad.Views.Search.SubTabs.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('do-search', @select_walmart_tab)
    @controller.bind('search:walmart-items:index', @select_walmart_tab)
    @controller.bind('search:amazon-items:index', @select_amazon_tab)
  data:
    query: null

  events:
    'click li.search-walmart-items-tab': 'walmart_items'
    'click li.search-amazon-items-tab': 'amazon_items'

  template: JST['backbone/templates/poor_performing/search_sub_tabs']

  update_url: (path) =>
    if @data.query
      newPath = Utils.UpdateURLParam(window.location.hash, 'query',
        @data.query)
      @router.navigate(path + newPath)

  toggleTab: (e) =>
    @$el.find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')

  walmart_items: (e) =>
    @controller.trigger('search:content-cleanup')
    e.preventDefault()
    @controller.trigger('search:walmart-items:index', @data)
    @router.update_path('search/query/' + @data.query)
  
  amazon_items: (e) =>
    @controller.trigger('search:content-cleanup')
    e.preventDefault()
    @controller.trigger('search:amazon-items:index', @data)
    @router.update_path('search/amazon_items/query/' + @data.query)

  select_walmart_tab: (data) =>
    @data.query = data.query if data and data.query
    unless @$el.find('ul.nav').length > 0
      @$el.append( @template())
    e = {}
    e.target = @$el.find('li.search-walmart-items-tab a').get(0)
    @toggleTab(e)
  
  select_amazon_tab: (data) =>
    @data.query = data.query if data and data.query
    unless @$el.find('ul.nav').length > 0
      @$el.append( @template())
    e = {}
    e.target = @$el.find('li.search-amazon-items-tab a').get(0)
    @toggleTab(e)
    
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
