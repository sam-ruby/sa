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
        super(rawValue) + '%'

    class CurrencyFormatter extends Backgrid.NumberFormatter
      decimals: 2
      decimalSeparator: '.'
      orderSeparator: ','

      fromRaw: (rawValue) ->
        if rawValue == 0
          '$' + rawValue.toFixed(0)
        else
          '$' + super(rawValue)

    UpdateURLParam: updateURLParam
    PercentFormatter: PercentFormatter
    CurrencyFormatter: CurrencyFormatter
  
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
      else if name.match(/search-rel:index|search-kpi|do-search|poor-performing-stats:index|poor-performing:index|pp:stats:index|pp:walmart-items:index|pp:amazon-items:index/)
        if not current_view or current_view != 'daily'
          controller.set_view('daily')
          controller.trigger('view-change', view: 'daily')
    )
    
    Controller: controller
    Router: searchQualityRouter

  do ->
    router = SearchQualityApp.Router
    controller = SearchQualityApp.Controller
    weekView = new Searchad.Views.WeekPicker.IndexView(
      el: '#dp3')

    topTabsView = new Searchad.Views.TopTabs.IndexView(
      el: '#top-nav')

    searchQualityQueryView = new Searchad.Views.SearchQualityQuery.IndexView(
        el: '#search-quality-queries')
    searchQualityQueryView.listenTo(
      controller, 'search-rel:index', searchQualityQueryView.get_items)
    
    poorPerformingView = new Searchad.Views.PoorPerforming.IndexView(
      el: '#poor-performing-queries'
      events:
        'click a.query': (e) ->
          query = $(e.target).text()
          controller.trigger('pp:stats:index', query: query)
          new_path = 'poor_performing/stats/query/' + encodeURIComponent(query)
          router.update_path(new_path)
    )
    poorPerformingView.listenTo(
      controller, 'poor-performing:index', poorPerformingView.get_items)
    
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
   
    # Comp Analysis
    caView = new Searchad.Views.CompAnalysis.IndexView(
      el: '#ca-queries'
      events:
        'click a.query': (e) ->
          query = $(e.target).text()
          controller.trigger('ca:amazon-items:index', query: query)
          new_path = 'comp_analysis/amazon_items/query/' +
            encodeURIComponent(query)
          router.update_path(new_path)
    )
    caView.listenTo(
      controller, 'comp-analysis:index', caView.get_items)
    
    searchSubtabsView =
      new Searchad.Views.Search.SubTabs.IndexView(
        el: '#search-subtabs'
      )
    
    searchStatsView =
      new Searchad.Views.PoorPerforming.Stats.IndexView(
        el: '#search-stats-hcharts')
    searchStatsView.listenTo(controller, 'do-search',
      searchStatsView.get_items)

    searchWalmartItemsView =
      new Searchad.Views.PoorPerforming.WalmartItems.IndexView(
        el: '#search-subtabs-content')
    searchWalmartItemsView.listenTo(
      controller, 'do-search', searchWalmartItemsView.get_items)
    searchWalmartItemsView.listenTo(
      controller, 'search:walmart-items:index',
      searchWalmartItemsView.get_items)
    searchWalmartItemsView.listenTo(
      controller, 'search:content-cleanup',
      searchWalmartItemsView.unrender)
    
    searchAmazonItemsView =
      new Searchad.Views.PoorPerforming.AmazonItems.IndexView(
        el: '#search-subtabs-content')
    searchAmazonItemsView.listenTo(
      controller, 'search:amazon-items:index', searchAmazonItemsView.get_items)
    searchAmazonItemsView.listenTo(
      controller, 'search:content-cleanup', searchAmazonItemsView.unrender)

    searchKPI = new Searchad.Views.SearchKPI.IndexView(
      el: '#search-kpi'
      paid_dom_selector: '.hcharts-paid'
      unpaid_dom_selector: '.hcharts-unpaid'
    )
    searchKPI.listenTo(controller, 'search-kpi:index',
      searchKPI.get_items)
  
  Backbone.history.start()
  
  $('div.content').css('height', ($(window).height() + 50) + 'px')
  $('p.notice').hide()
  $('p.alert').hide()
  $('a.home-page').on('click', (e) ->
    e.preventDefault()
    SearchQualityApp.Controller.trigger('content-cleanup')
    SearchQualityApp.Router.navigate('/', trigger: true)
  )

