$ ->
 
  $('div.content').css('height', ($(window).height() + 50) + 'px')
  $('p.notice').hide()
  $('p.alert').hide()
  $('#dp3').datepicker()
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
        parts = location.split('/filters/')
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
  
  #router = new Searchad.Routers.PostsRouter(
    #{posts: [{'title': 'sam', 'id': 1, 'content': 'my name'},
    #{'title': 'seema', 'id': 2, 'content': 'my second content'}]})
  # A controller copy that everyone will hold on to subscribe and
  # publish the events
  #

  window.SearchQualityApp = do ->
    controller = _.extend({}, Backbone.Events)
    searchQualityRouter = new Searchad.Routers.SearchQualityDailiesRouter(
      controller: controller
    )
    
    queryItemsRouter = new Searchad.Routers.QueryItemsRouter(
      controller: controller
    )
    
    queryItemsView = new Searchad.Views.QueryItems.IndexView(
      controller: controller
    )
    
    searchQualityDailyView =
      new Searchad.Views.SearchQualityDailies.IndexView(
        controller: controller
        router: searchQualityRouter
      )
    

    Controller: controller
    QueryItemsView: queryItemsView
    SearchQualityDailyView: searchQualityDailyView
    SearchQualityRouter: searchQualityRouter
    QueryItemsRouter: queryItemsRouter
  
  $('#dp3').on('changeDate', (e) ->
    dateStr = e.date.getFullYear() + '-' + (e.date.getMonth() + 1) + '-' + e.date.getDate()
    currentPath = window.location.hash.replace('#', '')
    newPath = Utils.UpdateURLParam(currentPath, 'date', dateStr, true)
    SearchQualityApp.SearchQualityRouter.navigate(newPath)
    SearchQualityApp.Controller.trigger('date_changed', date: dateStr)
  )
  Backbone.history.start()
