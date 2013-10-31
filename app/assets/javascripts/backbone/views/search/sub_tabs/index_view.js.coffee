Searchad.Views.Search.SubTabs ||= {}

class Searchad.Views.Search.SubTabs.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('search:walmart-items:index', @select_walmart_tab)
    @controller.bind('search:amazon-items:index', @select_amazon_tab)
    
    @searchStatsView = new Searchad.Views.PoorPerforming.Stats.IndexView()
    @searchWalmartItemsView =
      new Searchad.Views.PoorPerforming.WalmartItems.IndexView()
    @searchAmazonItemsView =
      new Searchad.Views.PoorPerforming.AmazonItems.IndexView()
    @queryStatsCollection = new Searchad.Collections.QueryStatsDailyCollection()
    @queryStatsCollection.bind('reset', @render_overall_results)
  
  data:
    query: null

  events:
    'click li.search-walmart-items-tab': 'walmart_items'
    'click li.search-amazon-items-tab': 'amazon_items'
    'submit': 'do_search'
    'click button.search-btn': 'do_search'

  template: JST['backbone/templates/poor_performing/search_sub_tabs']
  search_form_template: JST['backbone/templates/search/form']

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

  select_stats_tab: (data) =>
    @data.query = data.query if data and data.query
    unless @$el.find('ul.nav').length > 0
      @$el.append( @template())
    e = {}
    e.target = @$el.find('li.search-stats-tab a').get(0)
    @toggleTab(e)

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
 
  do_search: (e) =>
    e.preventDefault()
    @query = @$el.find('input.search-query').val()
    @router.update_path('search/query/' + encodeURIComponent(@query))
    # render the overall results, sub tabs, amazon comp, walmart items
    @search_results_cleanup()
    @queryStatsCollection.get_items(query: @query)
    @select_stats_tab()
    chart_container = $('<div></div>')
    @$el.append(chart_container)
    @searchStatsView.$el = chart_container
    @searchStatsView.get_items(query: @query)
   
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()

  render: =>
    @active = true
    @$el.append(@search_form_template())
    @delegateEvents()

  cleanup: =>
    @$el.children().remove()

  search_results_cleanup: =>
    @$el.children().not('form').remove()

  render_overall_results: =>
    grid = new Backgrid.Grid(
      columns: [{
        name: 'query_count',
        label: 'Query Count'
        editable: false
        cell: 'number'},
        {name: 'query_pvr',
        label: 'Query PVR'
        editable: false
        cell: 'number'},
        {name: 'query_atc',
        label: 'Query ATC'
        editable: false
        cell: 'number'},
        {name: 'query_con',
        label: 'Query Conversion Rate'
        editable: false
        cell: 'number'},
        {name: 'query_revenue',
        label: 'Query Revenue'
        editable: false
        cell: 'number'}]
      collection: @queryStatsCollection)
    el = grid.render().$el
    el.css('margin-bottom', '5em')
    @$el.find('form').after(el)
    @$el.find('form').after($('<ul class="nav nav-pills"><li class="active"><a>Query stats for "' + @query + '"</a></li></ul>'))
  
  render_sub_tabs: =>

  render_query_stats: =>

  render_amazon_comp: =>

  render_walmart_items: =>
