Searchad.Views.CompAnalysis.SubTabs ||= {}

class Searchad.Views.CompAnalysis.SubTabs.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('ca:walmart-items:index', @select_walmart_tab)
    @controller.bind('ca:amazon-items:index', @select_amazon_tab)
  data:
    query: null

  events:
    'click li.ca-walmart-items-tab': 'walmart_items'
    'click li.ca-amazon-items-tab': 'amazon_items'

  template: JST['backbone/templates/comp_analysis/sub_tabs']

  update_url: (path) =>
    if @data.query
      newPath = Utils.UpdateURLParam(window.location.hash, 'query',
        @data.query)
      @router.navigate(path + newPath)

  toggleTab: (e) =>
    @$el.find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')

  walmart_items: (e) =>
    @controller.trigger('ca:content-cleanup')
    e.preventDefault()
    @controller.trigger('ca:walmart-items:index', @data)
    @router.update_path('comp_analysis/walmart_items/query/' + @data.query)
  
  amazon_items: (e) =>
    @controller.trigger('ca:content-cleanup')
    e.preventDefault()
    @controller.trigger('ca:amazon-items:index', @data)
    @router.update_path('comp_analysis/amazon_items/query/' + @data.query)

  select_walmart_tab: (data) =>
    @data.query = data.query if data and data.query
    unless @$el.find('ul.nav').length > 0
      @$el.append( @template())
    e = {}
    e.target = @$el.find('li.ca-walmart-items-tab a').get(0)
    @toggleTab(e)
  
  select_amazon_tab: (data) =>
    @data.query = data.query if data and data.query
    unless @$el.find('ul.nav').length > 0
      @$el.append( @template())
    e = {}
    e.target = @$el.find('li.ca-amazon-items-tab a').get(0)
    @toggleTab(e)
    
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
