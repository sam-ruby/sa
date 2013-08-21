$ ->
 
  $('div.content').css('height', ($(window).height() + 50) + 'px')
  $('p.notice').hide()
  $('p.alert').hide()
  $('#dp3').datepicker()
  
  $('#dashboard-search-quality-container').draggable(
    snap: true
  )
  
  $('#dashboard-poorly-performing-container').draggable(
    snap: true
  )

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

      if filter
        newFilter = updateParam(filterURL, fName, fValue)
        return pathURL + '/filters/' + newFilter
      else
        newPath = updateParam(pathURL, fName, fValue)
        return newPath + '/filters/' + filterURL

    UpdateURLParam: updateURLParam
  
  window.SearchQualityApp = do ->
    controller = _.extend({}, Backbone.Events)
    searchQualityRouter = new Searchad.Routers.SearchQualityQuery(
      controller: controller)

    searchQualityRouter.on('all', (name) ->
      return unless name.match(/route:/)
      date = window.location.hash.match(/filters\/date\/([^\/]+)/)
      if (date)
        $('#dp3').datepicker('update', date[1])
        controller.trigger('collections:update-date', date: date[1])
    )

    Controller: controller
    Router: searchQualityRouter

  do ->
    searchQualityQueryView =
      new Searchad.Views.SearchQualityQuery.IndexView(
        el: '#search-quality-queries')

    searchQualitySubtabsView =
      new Searchad.Views.SearchQualityQuery.SubTabs.IndexView(
        el: '#query-items-tab')
    
    queryItemsView = new Searchad.Views.SearchQualityQuery.QueryItems.IndexView(
      el: '#query-items-content')
    
    poorPerformingView = new Searchad.Views.PoorPerforming.IndexView(
      el: '#poor-performing-queries')
    
    dashboardView = new Searchad.Views.Dashboard.IndexView(
        el: '#dashboard')
 
    masterTabView = new Searchad.Views.MasterTab.IndexView(
        el: '.main-content-container')

    poorPerformingSubtabsView =
      new Searchad.Views.PoorPerforming.SubTabs.IndexView(
        el: '#poor-performing-subtabs')

    poorPerformingWalmartItemsView =
      new Searchad.Views.PoorPerforming.WalmartItems.IndexView(
        el: '#poor-performing-subtabs-content')
    
  $('#dp3').on('changeDate', (e) ->
    dateStr = e.date.getMonth() + 1 + '-' + e.date.getDate() + '-' +
      e.date.getFullYear()
    currentPath = window.location.hash.replace('#', '')
    newPath = Utils.UpdateURLParam(currentPath, 'date', dateStr, true)
    SearchQualityApp.Router.navigate(newPath)
    SearchQualityApp.Controller.trigger('date-changed', date: dateStr)
  )
  Backbone.history.start()
