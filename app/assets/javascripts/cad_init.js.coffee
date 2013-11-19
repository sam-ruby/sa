$ ->
  window.Utils = do ->
    updateParam = (str, pName, pValue) ->
      if str is ''
        parts = []
      else
        parts = str.split('/')
      partsCopy = parts.slice(0)

      for name, i in parts when name is pName
        partsCopy.splice(i, 2)
      partsCopy.push(pName, pValue)
      partsCopy.join('/')

    updateURLParam = (location, fName, fValue, filter=false) ->
      if location.indexOf('filters') >=0
        parts = location.split('filters/')
        filterURL = parts[1]
        pathURL = parts[0]
      else
        filterURL = ''
        pathURL = location
      pathURL += '/' if pathURL.lastIndexOf('/') != (pathURL.length - 1)

      if filter
        newFilter = updateParam(filterURL, fName, fValue)
        return pathURL + 'filters/' + newFilter
      else
        newPath = updateParam(pathURL, fName, fValue)
        return newPath + 'filters/' + filterURL
     
    class PercentFormatter extends Backgrid.NumberFormatter
      decimals: 2
      decimalSeparator: '.'
      orderSeparator: ','

      fromRaw: (rawValue) ->
        return '-' if !rawValue?
        "#{super(rawValue)}%"
        
    class CustomNumberFormatter extends Backgrid.NumberFormatter
      decimals: 2
      decimalSeparator: '.'
      orderSeparator: ','

      fromRaw: (rawValue) ->
        return '-' unless rawValue
        super(rawValue)

    class CurrencyFormatter extends Backgrid.NumberFormatter
      decimals: 2
      decimalSeparator: '.'
      orderSeparator: ','

      fromRaw: (rawValue) ->
        if rawValue == 0
          '$' + rawValue.toFixed(0)
        else if rawValue < 0
          '- $' + super(Math.abs(rawValue))
        else if rawValue > 0
          '$' + super(rawValue)
        else
          '-'
    UpdateURLParam: updateURLParam
    PercentFormatter: PercentFormatter
    CurrencyFormatter: CurrencyFormatter
    CustomNumberFormatter: CustomNumberFormatter
  
  window.SearchQualityApp = do ->
    controller = _.extend({}, Backbone.Events)
    controller.set_view = (@view) =>
    controller.get_view = => @view
    controller.set_date = (@date) =>
    controller.set_week = (@week) =>
    controller.set_year = (@year) =>
    controller.set_cat_id = (@cat_id) =>

    controller.get_filter_params = =>
      date: @date
      week: @week
      year: @year
      cat_id: @cat_id

    controller.set_date(Selected_Date.toString('M-d-yyyy'))
    controller.set_week(Selected_Week)
    controller.set_year(Selected_Year)
    
    searchQualityRouter = new Searchad.Routers.SearchQualityQuery(
      controller: controller)

    controller.on('all', (name) ->
      current_view = controller.get_view()
      if name.match(/comp-analysis:index|ca:walmart-items:index/)
        if not current_view or current_view != 'weekly'
          controller.set_view('weekly')
          controller.trigger('view-change', view: 'weekly')
      else if name.match(/search-rel:index|search-kpi|do-search|poor-performing-stats:index|poor-performing:index|pp:stats:index|pp:walmart-items:index|pp:amazon-items:index|query-comparison|search:app/)
        if not current_view or current_view != 'daily'
          controller.set_view('daily')
          controller.trigger('view-change', view: 'daily'))
    
    Controller: controller
    Router: searchQualityRouter

  do ->
    router = SearchQualityApp.Router
    controller = SearchQualityApp.Controller
    weekView = new Searchad.Views.WeekPicker.IndexView(
      el: '#dp3')

    topTabsView = new Searchad.Views.TopTabs.IndexView(
      el: '#top-nav')

    searchKPI = new Searchad.Views.SearchKPI.IndexView(
      el: '#search-kpi'
      paid_dom_selector: '.hcharts-paid'
      unpaid_dom_selector: '.hcharts-unpaid'
    )
    searchKPI.listenTo(controller, 'search-kpi:index',
      searchKPI.get_items)

    poorPerformingView = new Searchad.Views.PoorPerforming.IndexView(
      el: '#poor-performing-queries')
    poorPerformingView.listenTo(
      controller, 'poor-performing:index', poorPerformingView.get_items)

    searchQualityQueryView = new Searchad.Views.SearchQualityQuery.IndexView(
      el: '#search-quality-queries')
    searchQualityQueryView.listenTo(
      controller, 'search-rel:index', searchQualityQueryView.get_items)
    
    # Comp Analysis
    ###
    caView = new Searchad.Views.CompAnalysis.IndexView(
      el: '#ca-queries')
    caView.listenTo(
      controller, 'comp-analysis:index', caView.get_items)
    ###
    # Search
    searchView = new Searchad.Views.Search.IndexView(
      el: '#search-form'
      el_results: '#search-results')
    searchView.listenTo(
      controller, 'search:form', searchView.render)
    searchView.listenTo(
      controller, 'load-search-results', searchView.load_search_results)

    subtabsView =
      new Searchad.Views.Search.SubTabs.IndexView(el: '#search-sub-tabs')
    subtabsView.listenTo(
      controller, 'search:sub-content', subtabsView.render)
   
    searchStatsView = new Searchad.Views.Search.Stats.IndexView(
      el: '#search-sub-content')
    searchStatsView.listenTo(
      controller, 'search:stats', searchStatsView.get_items)

    searchWalmartItemsView = new Searchad.Views.Search.WalmartItems.IndexView(
      el: '#search-sub-content')
    searchWalmartItemsView.listenTo(
      controller, 'search:walmart-items', searchWalmartItemsView.get_items)

    amazonStatsView =
      new Searchad.Views.Search.AmazonItems.Stats.IndexView(
        el: '#search-sub-content')
    amazonStatsView.listenTo(
      controller, 'search:amazon-items:stats', amazonStatsView.render)

    amazonItemsView =
      new Searchad.Views.Search.AmazonItems.IndexView(
        el: '#search-amazon-content')
    amazonItemsView.listenTo(
      controller, 'search:amazon-items', amazonItemsView.get_items)
    
    queryItemsView = new Searchad.Views.Search.RelRev.IndexView(
      el: '#search-sub-content')
    queryItemsView.listenTo(
      controller, 'search:rel-rev', (data) ->
        queryItemsView.get_items(data)
    )

    # Search Comparison
    searchComparisonView =
      new Searchad.Views.SearchComparison.IndexView(
        el: '#query-comparison-fcharts'
        form_selector: '.query-form'
        before_selector: '.before-data'
        after_selector: '.after-data'
        comparison_selector: '.comparison-data'
        recent_searches_selector: '.recent-searches'
      )
    searchComparisonView.listenTo(controller, 'query-comparison',
      searchComparisonView.get_items)
    
    ###
    searchStatsView = new Searchad.Views.Search.Stats.IndexView(
      el: '#search-sub-content')
    searchStatsView.listenTo(
      controller, 'search:stats', searchStatsView.get_items)
    ###
    #
    ###
    amazonItemsView =
      new Searchad.Views.PoorPerforming.AmazonItems.IndexView(
        el: '#ca-subtabs-content'
        top_32_tab: '#ca-amazon-top-subtabs'
        view: 'weekly')
    amazonItemsView.listenTo(
      @controller, 'ca:amazon-items:index', amazonItemsView.get_items)
    amazonItemsView.listenTo(
      @controller, 'ca:content-cleanup', amazonItemsView.unrender)
    
    amazonItemsView.listenTo(
      @controller, 'ca:amazon-items:all-items',
      amazonItemsView.render_all_items)
    amazonItemsView.listenTo(
      @controller, 'ca:amazon-items:in-top-32',
      amazonItemsView.render_in_top_32)
    amazonItemsView.listenTo(
      @controller, 'ca:amazon-items:not-in-top-32',
      amazonItemsView.render_not_in_top_32)

    amazonItemsView.collection.on('reset', ->
      if @collection.at(0).get('all_items').length > 0
        @controller.trigger('ca:amazon-items:overlap',
          query: @query
          collection: @collection)
    , amazonItemsView)
    @controller.bind('ca:amazon-items:in-top-32', @render_in_top_32)
    @controller.bind('ca:amazon-items:not-in-top-32', @render_not_in_top_32)
    
    amazonStatsView =
      new Searchad.Views.CompAnalysis.AmazonItemsChart.IndexView(
        el: '#ca-amazon-overlap')
    amazonStatsView.listenTo(
      @controller, 'ca:amazon-items:overlap', amazonStatsView.render)
    amazonStatsView.listenTo(
      @controller, 'ca:content-cleanup', amazonStatsView.unrender)

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


    ppSubtabsView = new Searchad.Views.PoorPerforming.SubTabs.IndexView(
        el: '#poor-performing-subtabs')
    
    ppWalmartItemsView = new Searchad.Views.PoorPerforming.WalmartItems.IndexView(
        el: '#poor-performing-subtabs-content')
    ppWalmartItemsView.listenTo(
      controller, 'pp:walmart-items:index', ppWalmartItemsView.get_items)
    ppWalmartItemsView.listenTo(
      controller, 'pp:content-cleanup', ppWalmartItemsView.unrender)
    
    ppStatsView = new Searchad.Views.PoorPerforming.Stats.IndexView(
        el: '#hcharts')
    ppStatsView.listenTo(
      controller, 'pp:stats:index', ppStatsView.get_items)
    ppStatsView.listenTo(
      controller, 'pp:content-cleanup', ppStatsView.unrender)
    
    ppAmazonItemsView = new Searchad.Views.PoorPerforming.AmazonItems.IndexView(
        el: '#poor-performing-subtabs-content')
    ppAmazonItemsView.listenTo(
      controller, 'pp:amazon-items:index', ppAmazonItemsView.get_items)
    ppAmazonItemsView.listenTo(
      controller, 'pp:content-cleanup', ppAmazonItemsView.unrender)
    ###
      
  Backbone.history.start()
  
  $('div.content').css('height', ($(window).height() + 50) + 'px')
  $('p.notice').hide()
  $('p.alert').hide()
  $('a.home-page').on('click', (e) ->
    e.preventDefault()
    SearchQualityApp.Controller.trigger('content-cleanup')
    SearchQualityApp.Router.navigate('/', trigger: true)
  )
  MDW.init({appId: 8880394})

