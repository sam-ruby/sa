Searchad.Views.Dashboard ||= {}

class Searchad.Views.Dashboard.IndexView extends Backbone.View
  initialize: (options, filters) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('dashboard:index', @renderFrame)
    @controller.bind('content-cleanup', @unrenderFrame)
    
    #Initialize the dashboard views
    searchQueryItemsView =
      new Searchad.Views.SearchQualityQuery.IndexView(
        el: "#dashboard-search-quality-container .content"
        controller: @controller
        events:
          'click a.query': (e) =>
            @controller.trigger('content-cleanup')
            @controller.trigger('search-rel:index')

      )
    searchQueryItemsView.listenTo(@controller, 'dashboard:index',
      searchQueryItemsView.get_items)
      
    poorPerformingView =
      new Searchad.Views.PoorPerforming.IndexView(
        el: "#dashboard-poorly-performing-container .content"
        controller: @controller
        events:
          'click a.query': (e) =>
            query = $(e.target).text()
            @controller.trigger('content-cleanup')
            @controller.trigger('poor-performing:index')
            @controller.trigger('pp:stats', query: query)
            new_path = 'poor_performing/stats/query/' + query
            @router.update_path(new_path)
      )
    poorPerformingView.listenTo(@controller, 'dashboard:index',
      poorPerformingView.get_items)

  renderFrame: (data) =>
    @$el.show()
    @$el.children().show()
    @controller.trigger('dashboard:search-quality:index', data)
    @controller.trigger('dashboard:poor-performing:index', data)
  
  unrenderFrame: =>
    @$el.children().hide()

