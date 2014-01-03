Searchad.Views.SubTabs ||= {}

class Searchad.Views.SubTabs.IndexView extends Backbone.View
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

  stats: (e) =>
    @toggleTab(e)
    @controller.trigger('search:stats', query: @query)
    # change user latest click tab to store stats, so when user stwitch between queries, 
    # the tab won't jump from one to anoter
    Searchad.UserLatest.sub_tabs.current_tab = "stats"
 

  walmart_items: (e) =>
    @toggleTab(e)
    @controller.trigger('search:walmart-items',
      query: @query
      view: @view)
    Searchad.UserLatest.sub_tabs.current_tab = "walmart"

  
  amazon_items: (e) =>
    @toggleTab(e)
    @controller.trigger('search:amazon-items',
      query: @query
      view: @view)
    Searchad.UserLatest.sub_tabs.current_tab = "amazon"


  rev_rel: (e) =>
    @toggleTab(e)
    @controller.trigger('search:rel-rev',
      query: @query
      view: @view)
    Searchad.UserLatest.sub_tabs.current_tab = "rel-rev-analysis"


  show_cvr_dropped_item_comparison:(e)=>
    @toggleTab(e)
    # @select_cvr_dropped_item_comparison_tab()
    @controller.trigger('cvr_dropped_query:item_comparison',
      query: @data.query
      query_date: @data.query_date
      weeks_apart: @data.weeks_apart
    )
    Searchad.UserLatest.sub_tabs.current_tab = "cvr-dropped-item-comparison"


  toggleTab: (e) =>
    e.preventDefault()
    @$el.find('li.active').removeClass('active')
    $(e.target).parent().addClass('active')
    @controller.trigger('sub-content-cleanup')


  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @hide_spin()


  render: (data) =>
    @query = data.query if data.query
    @view = data.view if data.view
    @data = data;
    @$el.prepend(@template()) unless @active
    @delegateEvents() 
    if data.tab =='cvr-dropped-item-comparison'
      @$el.find('li.cvr-dropped-item-comparison-tab').show();
      @$el.find('li.cvr-dropped-item-comparison-tab a').first().click()  
    else
      @$el.find('li.cvr-dropped-item-comparison-tab').hide();
      if data.tab == 'rel-rev-analysis'
        @$el.find('li.rev-rel-tab a').first().click()
      else if data.tab == 'amazon'
        @$el.find('li.search-amazon-items-tab a').first().click()
      else if data.tab == 'walmart'
        @$el.find('li.search-walmart-items-tab a').first().click()
      else
        @$el.find('li.search-stats-tab').first().click()
    @active = true


  show_spin: =>
    @$el.find('.ajax-loader').css('display', 'block')
  

  hide_spin: =>
    @$el.find('.ajax-loader').hide()
