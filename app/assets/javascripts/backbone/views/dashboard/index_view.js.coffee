Searchad.Views.Dashboard ||= {}

class Searchad.Views.Dashboard.IndexView extends Backbone.View
  initialize: (options, filters) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('dashboard:index', @renderFrame)
    @controller.bind('content-cleanup', @unrenderFrame)
    
    
    #Initialize the dashboard views
    @searchQueryItemsView =
      new Searchad.Views.Dashboard.SearchQualityQuery.IndexView(
        el: "#dashboard-search-quality-container .content"
        controller: @controller
      )
      
    @poorlyPerformingView =
      new Searchad.Views.Dashboard.PoorlyPerforming.IndexView(
        el: "#dashboard-poorly-performing-container .content"
        controller: @controller
      )
  
  renderFrame: (data) =>
    @$el.show()
    @$el.children().show()
    @controller.trigger('dashboard:search-quality:index', data)
    @controller.trigger('dashboard:poor-performing:index', data)
  
  unrenderFrame: =>
    @$el.children().hide()

