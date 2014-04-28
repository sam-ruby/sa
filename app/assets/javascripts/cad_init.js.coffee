$ ->
  do ->
    router = new Searchad.Routers.SearchQualityQuery()
    SearchQualityApp.Router = router
    controller = SearchQualityApp.Controller
    controller.set_date(Selected_Date.toString('M-d-yyyy'))
    # comment out cuz we never select week or year, in CAD we only select dates
    # if we need what week or year it is, there is a function in backend to process that
    # controller.set_week(Selected_Week)
    # controller.set_year(Selected_Year)

    controller.on('all', (name) ->
      current_view = controller.get_view()
      if name.match(/search-rel:index|search-kpi|do-search|poor-performing-stats:index|poor-performing:index|pp:stats:index|pp:walmart-items:index|pp:amazon-items:index|adhoc_query|query-monitoring-count:index/)
        if not current_view or current_view != 'daily'
          controller.set_view('daily')
          controller.trigger('view-change', view: 'daily'))
    
    categoriesView = new Searchad.Views.Categories.IndexView(
      el: '#cat-container')
    weekView = new Searchad.Views.WeekPicker.IndexView(
      el: '#dp3')

    topTabsView = new Searchad.Views.TopTabs.IndexView(
      el: '#top-bar')
    
    searchTabsView = new Searchad.Views.SearchTabs.IndexView(
      el: '#search-bar')

    browseTabsView = new Searchad.Views.BrowseTabs.IndexView(
      el: '#browse-bar')
    
    categoryTabsView = new Searchad.Views.CategoryTabs.IndexView(
      el: '#category-bar')

    masterTabView = new Searchad.Views.MasterTab.IndexView(
      el: '#search-sub-tasks .tabs')

    poorPerformingView = new Searchad.Views.PoorPerforming.IndexView(
      el: '#search-sub-tasks .search-content')

    upTrendingView = new Searchad.Views.UpTrending.IndexView(
      el: '#search-sub-tasks .search-content')
    
    overallMetricsView = new Searchad.Views.OverallMetrics(
      el: '#overall-metrics')
    
    summaryMetricsView = new Searchad.Views.SummaryMetrics(
      el: '#summary-metrics')
  
    oNdcg_5_WinnersView = new Searchad.Views.ONdcg5(
      el: '#winners')
    
    oMpr_5_WinnersView = new Searchad.Views.OMpr5(
      el: '#winners')
 
    oPrec_5_WinnersView = new Searchad.Views.OPrec5(
      el: '#winners')
    
    oRecall_5_WinnersView = new Searchad.Views.ORec5(
      el: '#winners')
    
    oNdcg_1_WinnersView = new Searchad.Views.ONdcg1(
      el: '#winners')
    
    oMpr_1_WinnersView = new Searchad.Views.OMpr1(
      el: '#winners')
 
    oPrec_1_WinnersView = new Searchad.Views.OPrec1(
      el: '#winners')
    
    oRecall_1_WinnersView = new Searchad.Views.ORec1(
      el: '#winners')

    oNdcg_16_WinnersView = new Searchad.Views.ONdcg16(
      el: '#winners')
    
    oMpr_16_WinnersView = new Searchad.Views.OMpr16(
      el: '#winners')
 
    oPrec_16_WinnersView = new Searchad.Views.OPrec16(
      el: '#winners')
    
    oRecall_16_WinnersView = new Searchad.Views.ORec16(
      el: '#winners')

    #convCorWinnersView = new Searchad.Views.ConvCorrelation.Winners(
    # el: '#winners')
   
    trafficWinnersView = new Searchad.Views.Traffic.Winners(
      el: '#winners')
   
    pvrWinnerView = new Searchad.Views.Pvr.Winners(
      el: '#winners')
   
    atcWinnerView = new Searchad.Views.Atc.Winners(
      el: '#winners')
   
    conversionWinnerView = new Searchad.Views.Conversion.Winners(
      el: '#winners')
   
    revenueWinnerView = new Searchad.Views.Revenue.Winners(
      el: '#winners')
   
    oosWinnerView = new Searchad.Views.Oos.Winners(
      el: '#winners')
   
    searchKPI = new Searchad.Views.SearchKPI.IndexView(
      el: '#search-kpi'
      paid_dom_selector: '.hcharts-paid'
      unpaid_dom_selector: '.hcharts-unpaid'
    )
    searchKPI.listenTo(controller, 'search-kpi:index',
      searchKPI.get_items)

    searchQualityQueryView = new Searchad.Views.SearchQualityQuery.IndexView(
      el: '#search-quality-queries'
      el_filter: '#search-quality-filter'
    )
    searchQualityQueryView.listenTo(
      controller, 'search-rel:index', searchQualityQueryView.get_items)
    
    # Search
    searchView = new Searchad.Views.AdhocQuery.SimpleSearchView(
      el: '#adhoc-query-report'
      el_results: '#search-results'
      )
    searchView.listenTo(
      controller, 'adhoc:search', (data) -> searchView.do_search(data))
    searchView.listenTo(
      controller, 'load-search-results', searchView.load_search_results)

    subtabsView =
      new Searchad.Views.SubTabs.IndexView(el: '#search-sub-tabs')
    subtabsView.listenTo(
      controller, 'search:details', subtabsView.render)
   
    searchStatsView = new Searchad.Views.SubTabs.Stats.IndexView(
      el: '#search-sub-content')
    searchStatsView.listenTo(
      controller, 'search:stats', searchStatsView.get_items)

    searchWalmartItemsView = new Searchad.Views.SubTabs.WalmartItems.IndexView(
      el: '#search-sub-content')
    searchWalmartItemsView.listenTo(
      controller, 'search:walmart-items', searchWalmartItemsView.render)

    amazonStatsView =
      new Searchad.Views.SubTabs.AmazonItems.Stats.IndexView(
        el: '#search-sub-content')
    amazonStatsView.listenTo(
      controller, 'search:amazon-items:stats', amazonStatsView.render)

    amazonItemsView =
      new Searchad.Views.SubTabs.AmazonItems.IndexView(
        el: '#search-amazon-content')
    amazonItemsView.listenTo(
      controller, 'search:amazon-items', amazonItemsView.get_items)
    
    queryItemsView = new Searchad.Views.SubTabs.RelRev.IndexView(
      el: '#search-sub-content')
    queryItemsView.listenTo(
      controller, 'search:rel-rev', (data) ->
        queryItemsView.get_items(data)
    )

    #cvr dropped view
    cvrDroppedQueryView = new Searchad.Views.AdhocQuery.cvrDroppedQueryView (
      el: '#adhoc-query-report'
      el_results: '#cvr-dropped-query-results'
      )

    cvrDroppedQueryView.listenTo(
        controller, 'adhoc:cvr_dropped_query',
        (data) -> cvrDroppedQueryView.get_items(data))

    #cvr_dropped_view when click on q query show the item comparison
    #regarding that query
    cvrDroppedQueryItemComparisonView =
      new Searchad.Views.SubTabs.ItemComparisonView(el: '#search-sub-content')

    cvrDroppedQueryItemComparisonView.listenTo(
      controller, 'cvr_dropped_query:item_comparison', (data) ->
         cvrDroppedQueryItemComparisonView.get_items(data)
    )
    
    adhocQueryView = new Searchad.Views.AdhocQuery.IndexView(
      el: '#adhoc-query-report'
      el_form: '#cvr-dropped-query-form'
    )
    adhocQueryView.listenTo(
      controller, 'adhoc:toggle_search_mode',
      (query_comparison_on)->
        adhocQueryView.toggle_search_mode(query_comparison_on))

    adhocQueryView.listenTo(
      controller, 'adhoc:index',(data)->adhocQueryView.render_form(data))

    queryMonitoringCountView =
      new Searchad.Views.QueryMonitoring.Count.IndexView(el: '#query-monitoring')
    queryMonitoringCountView.listenTo(
      controller, 'query-monitoring-count:index', (data) ->
        queryMonitoringCountView.get_items(data)
    )
    qmSubtabsView =
      new Searchad.Views.QueryMonitoring.SubTabs.IndexView(el: '#qm-count-sub-tabs')
    qmSubtabsView.listenTo(
      controller, 'qm:sub-content', qmSubtabsView.render)
 
    qmCountStatsView =
      new Searchad.Views.QueryMonitoring.Count.Stats.IndexView(
        el: '#qm-count-sub-content')
    qmCountStatsView.listenTo(
      controller, 'qm-count:stats', qmCountStatsView.get_items)

    queryMonitoringMetricView = new Searchad.Views.QueryMonitoring.Metric.IndexView(el: '#query-monitoring')
    queryMonitoringMetricView.listenTo(
      controller, 'qm-metrics:index', (data) ->
        queryMonitoringMetricView.get_items(data)
    )

    qmMetricStatsView = new Searchad.Views.QueryMonitoring.Metric.Stats.IndexView (
      el: '#qm-count-sub-content'
      con_el:'#con-stats'
      atc_el:'#atc-stats'
      pvr_el:'#pvr-stats'
    )
    qmCountStatsView.listenTo(
      controller, 'qm-metrics:stats',
      (data)-> qmMetricStatsView.get_items(data))

  Backbone.history.start()
  
  $('div.content').css('height', ($(window).height() + 50) + 'px')
  $('p.notice').hide()
  $('p.alert').hide()
  $('a.home-page').on('click', (e) ->
    e.preventDefault()
    SearchQualityApp.Router.navigate('/', trigger: true)
  )


  # Enable feedback widget
  $.feedback(
    ajaxURL: '/feedback/send_feedback'
    html2canvasURL: 'assets/feedback-master/html2canvas.js')
  
  #MDW.init({appId: 429415118})

