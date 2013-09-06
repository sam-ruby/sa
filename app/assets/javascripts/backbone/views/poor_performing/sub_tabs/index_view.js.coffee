Searchad.Views.PoorPerforming.SubTabs ||= {}

class Searchad.Views.PoorPerforming.SubTabs.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('pp:stats:index', @select_stats_tab)
    @controller.bind('pp:walmart-items:index', @select_walmart_tab)
    @controller.bind('pp:amazon-items:index', @select_amazon_tab)
  data:
    query: null

  events:
    'click li.pp-stats-tab': 'stats'
    'click li.pp-walmart-items-tab': 'walmart_items'
    'click li.pp-amazon-items-tab': 'amazon_items'

  template: JST['backbone/templates/poor_performing/sub_tabs']

  update_url: (path) =>
    if @data.query
      newPath = Utils.UpdateURLParam(window.location.hash, 'query',
        @data.query)
      @router.navigate(path + newPath)

  toggleTab: (e) =>
    @$el.find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')

  walmart_items: (e) =>
    @controller.trigger('pp:content-cleanup')
    e.preventDefault()
    @controller.trigger('pp:walmart-items:index', @data)
    @router.update_path('poor_performing/walmart_items/query/' + @data.query)
  
  stats: (e) =>
    @controller.trigger('pp:content-cleanup')
    e.preventDefault()
    @controller.trigger('pp:stats:index', @data)
    @router.update_path('poor_performing/stats/query/' + @data.query)

  amazon_items: (e) =>
    @controller.trigger('pp:content-cleanup')
    e.preventDefault()
    @controller.trigger('pp:amazon-items:index', @data)
    @router.update_path('poor_performing/amazon_items/query/' + @data.query)

  select_walmart_tab: (data) =>
    @data.query = data.query if data and data.query
    unless @$el.find('ul.nav').length > 0
      @$el.append( @template())
    e = {}
    e.target = @$el.find('li.pp-walmart-items-tab a').get(0)
    @toggleTab(e)
  
  select_amazon_tab: (data) =>
    @data.query = data.query if data and data.query
    unless @$el.find('ul.nav').length > 0
      @$el.append( @template())
    e = {}
    e.target = @$el.find('li.pp-amazon-items-tab a').get(0)
    @toggleTab(e)
  
  select_stats_tab: (data) =>
    @data.query = data.query if data and data.query
    unless @$el.find('ul.nav').length > 0
      @$el.append( @template())
    e = {}
    e.target = @$el.find('li.pp-stats-tab a').get(0)
    @toggleTab(e)
    
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
