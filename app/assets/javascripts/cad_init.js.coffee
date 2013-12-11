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

    init_csv_export_feature = (view, url) ->
      view.export_csv_button = _.template('<span class="label label-info export-csv pull-right"><a href="#" id="download-csv-btn"><i class="icon icon-download-alt">&nbsp;</i>Download</a></span>')
      view.export_csv = view.export_csv || (el, fileName, data) =>
        MDW.CSVExport.genDownloadCSVFromUrl(el, fileName, url, data)
     
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
    InitExportCsv: init_csv_export_feature
  
  do ->
    router = new Searchad.Routers.SearchQualityQuery()
    SearchQualityApp.Router = router
    controller = SearchQualityApp.Controller
    
    controller.set_date(Selected_Date.toString('M-d-yyyy'))
    controller.set_week(Selected_Week)
    controller.set_year(Selected_Year)

    controller.on('all', (name) ->
      current_view = controller.get_view()
      if name.match(/search-rel:index|search-kpi|do-search|poor-performing-stats:index|poor-performing:index|pp:stats:index|pp:walmart-items:index|pp:amazon-items:index|query-comparison|search:form|query-monitoring-count:index/)
        if not current_view or current_view != 'daily'
          controller.set_view('daily')
          controller.trigger('view-change', view: 'daily'))
    

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
      el: '#search-quality-queries'
      el_filter: '#search-quality-filter'
    )
    searchQualityQueryView.listenTo(
      controller, 'search-rel:index', searchQualityQueryView.get_items)
    
    # Search
    searchView = new Searchad.Views.Search.IndexView(
      el: '#search'
      el_results: '#search-results'
      el_form: '#search-form')
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
        form_selector: '#query-form'
        before_selector: '#before-data'
        after_selector: '#after-data'
        comparison_selector: '#comparison-data'
        recent_searches_selector: '#recent-searches'
      )
    searchComparisonView.listenTo(controller, 'query-comparison:index',
      searchComparisonView.get_items)

     #cvr dropped view
    cvrDroppedQueryView = new Searchad.Views.CVRDroppedQuery.IndexView(
      el: '#cvr-dropped-query'
      el_results: '.cvr-dropped-query-results'
      el_form: '.cvr-dropped-query-form')
    cvrDroppedQueryView.listenTo(
        controller, 'cvr-dropped-query:index',cvrDroppedQueryView.render_form)
    cvrDroppedQueryView.listenTo(
      controller, 'cvr-dropped-query:result', cvrDroppedQueryView.get_items)

    #cvr_dropped_view when click on q query show the item comparison regarding that query
    cvrDroppedQueryItemComparisonView = new Searchad.Views.CVRDroppedQuery.ItemComparisonView {
      el: '.cvr-dropped-query-item-comparison'
    }
    cvrDroppedQueryItemComparisonView.listenTo(
      controller, 'cvr_dropped_query:item_comparison', (data) ->
         cvrDroppedQueryItemComparisonView.get_items(data)
    )
    
    queryMonitoringCountView =
      new Searchad.Views.QueryMonitoring.Count.IndexView(
        el: '#qm-count'
        el_filter: '#qm-count-filter')
    queryMonitoringCountView.listenTo(
      controller, 'query-monitoring-count:index', (data) ->
        queryMonitoringCountView.get_items(data)
    )
    qmCountSubtabsView =
      new Searchad.Views.QueryMonitoring.SubTabs.IndexView(el: '#qm-count-sub-tabs')
    qmCountSubtabsView.listenTo(
      controller, 'qm-count:sub-content', qmCountSubtabsView.render)
 
    qmCountStatsView =
      new Searchad.Views.QueryMonitoring.Count.Stats.IndexView(
        el: '#qm-count-sub-content')
    qmCountStatsView.listenTo(
      controller, 'qm-count:stats', qmCountStatsView.get_items)
   
  Backbone.history.start()
  
  $('div.content').css('height', ($(window).height() + 50) + 'px')
  $('p.notice').hide()
  $('p.alert').hide()
  $('a.home-page').on('click', (e) ->
    e.preventDefault()
    SearchQualityApp.Router.navigate('/', trigger: true)
  )
  MDW.init({appId: 429415118})

