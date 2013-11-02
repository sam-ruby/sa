Searchad.Views.Search.SubTabs ||= {}

class Searchad.Views.Search.SubTabs.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    
    @$search_results = $(options.el_results)
    @$search_sub_content = $(options.el_sub_content)
    @$search_sub_tab = $(options.el_sub_tab)
    @bind_sub_tab_click()

    @controller.bind('content-cleanup', @unrender)
    @controller.bind('search:walmart-items:index', @select_walmart_tab)
    @controller.bind('search:amazon-items:index', @select_amazon_tab)
    
    @searchStatsView = new Searchad.Views.PoorPerforming.Stats.IndexView(
      el: options.el_sub_content)
    @searchStatsView.listenTo(
      @controller, 'search:stats', @searchStatsView.get_items)
    @searchStatsView.listenTo(
      @controller, 'search:sub-content-cleanup', @searchStatsView.unrender)

    @searchWalmartItemsView =
      new Searchad.Views.PoorPerforming.WalmartItems.IndexView(
        el: options.el_sub_content)
    @searchWalmartItemsView.listenTo(
      @controller, 'search:walmart-items', @searchWalmartItemsView.get_items)
    @searchWalmartItemsView.listenTo(
      @controller, 'search:sub-content-cleanup', @searchWalmartItemsView.unrender)
    
    @searchAmazonItemsView =
      new Searchad.Views.PoorPerforming.AmazonItems.IndexView(
        el: options.el_sub_content)
    @searchAmazonItemsView.listenTo(
      @controller, 'search:amazon-items', @searchAmazonItemsView.get_items)
    @searchStatsView.listenTo(
      @controller, 'search:sub-content-cleanup', @searchStatsView.unrender)

    @queryStatsCollection = new Searchad.Collections.QueryStatsDailyCollection()
    @queryStatsCollection.bind('reset', @render_search_results)
  
  data:
    query: null

  events:
    'click li.search-stats-tab': 'stats'
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
    @$search_sub_tab.find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')

  stats: =>
    @controller.trigger('search:sub-content-cleanup')
    @select_stats_tab()
    @controller.trigger('search:stats', query: @query)
  
  walmart_items: =>
    @controller.trigger('search:sub-content-cleanup')
    @select_walmart_tab()
    @controller.trigger('search:walmart-items', query: @query)
  
  amazon_items: =>
    @controller.trigger('search:sub-content-cleanup')
    @select_amazon_tab()
    @controller.trigger('search:amazon-items', query: @query)

  bind_sub_tab_click: =>
    that = this
    @$search_sub_tab.on(
      'click', 'a', (e) ->
        e.preventDefault()
        if $(e.target).parents('li.search-walmart-items-tab').length > 0
          that.walmart_items()
        else if $(e.target).parents('li.search-amazon-items-tab').length > 0
          that.amazon_items()
        else if $(e.target).parents('li.search-stats-tab').length > 0
          that.stats()
    )

  select_stats_tab: (data) =>
    @data.query = data.query if data and data.query
    unless @$search_sub_tab.find('ul.nav').length > 0
      @$search_sub_tab.append(@template())
    e = {}
    e.target = @$search_sub_tab.find('li.search-stats-tab a').get(0)
    @toggleTab(e)

  select_walmart_tab: (data) =>
    @data.query = data.query if data and data.query
    unless @$search_sub_tab.find('ul.nav').length > 0
      @$search_sub_tab.append(@template())
    e = {}
    e.target = @$search_sub_tab.find('li.search-walmart-items-tab a').get(0)
    @toggleTab(e)
  
  select_amazon_tab: (data) =>
    @data.query = data.query if data and data.query
    unless @$search_sub_tab.find('ul.nav').length > 0
      @$search_sub_tab.append(@template())
    e = {}
    e.target = @$search_sub_tab.find('li.search-amazon-items-tab a').get(0)
    @toggleTab(e)
 
  do_search: (e) =>
    e.preventDefault()
    @search_results_cleanup()
    @controller.trigger('search:sub-content-cleanup')
    @$search_sub_tab.children().remove()
    @search_term = @$el.find('input.search-query').val()
    @router.update_path('search/query/' + encodeURIComponent(@search_term))
    
    # render the overall results, sub tabs, amazon comp, walmart items
    @queryStatsCollection.get_items(query: @search_term)
    @trigger = true

  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$search_results.children().not('.ajax-loader').remove()
    @$search_sub_tab.children().remove()
    @$el.find('.ajax-loader').hide()

  render: =>
    @active = true
    @$el.append(@search_form_template())
    @delegateEvents()

  cleanup: =>
    @$el.children().remove()

  search_results_cleanup: =>
    @$search_results.children().remove()

  query_cell: ->
    that = this
    class QueryCell extends Backgrid.Cell
      controller: SearchQualityApp.Controller
      events:
        'click': 'handleQueryClick'
      handleQueryClick: (e) =>
        e.preventDefault()
        $(e.target).parents('table').find('tr.selected').removeClass('selected')
        $(e.target).parents('tr').addClass('selected')
        that.controller.trigger('search:sub-content-cleanup')
        that.select_stats_tab()
        that.query = $(e.target).text()
        that.controller.trigger('search:stats', query: that.query)
      render: ->
        value = @model.get(@column.get('name'))
        formatted_value = '<a class="query" href="#">' + value + '</a>'
        @$el.html(formatted_value)
        @delegateEvents()
        return this

    return QueryCell

  render_search_results: =>
    @search_results_cleanup()
    if @queryStatsCollection.length == 0
      @$search_results.append(
        '<p class="text-error">No data available for "' +
        @search_term + '"')
      return

    @select_stats_tab()
    paginator = new Backgrid.Extension.Paginator(
      collection: @queryStatsCollection
    )
    grid = new Backgrid.Grid(
      columns: [{
        name: 'query'
        label: 'Query'
        editable: false
        cell: @query_cell()},
        {name: 'query_count'
        label: 'Query Count'
        editable: false
        cell: 'number'},
        {name: 'query_pvr'
        label: 'Query PVR'
        editable: false
        cell: 'number'},
        {name: 'query_atc'
        label: 'Query ATC'
        editable: false
        cell: 'number'},
        {name: 'query_con'
        label: 'Query Conversion Rate'
        editable: false
        cell: 'number'},
        {name: 'query_revenue'
        label: 'Query Revenue'
        editable: false
        cell: 'number'}]
      collection: @queryStatsCollection)
    
    @$search_results.append($('<div>').css('text-align', 'left').css(
      'margin-bottom': '1em').append(
      $('<i>').addClass('icon-search').css(
        'font-size', 'large').append(
        '&nbsp; Results for : ' + @search_term)))
    @$search_results.append( grid.render().$el )
    @$search_results.append( paginator.render().$el )
    if @trigger
      @trigger = false
      @$search_results.find('td a.query').first().trigger('click')
    
  render_sub_tabs: =>

  render_query_stats: =>

  render_amazon_comp: =>

  render_walmart_items: =>
