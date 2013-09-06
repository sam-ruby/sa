Searchad.Views.TopTabs ||= {}

class Searchad.Views.TopTabs.IndexView extends Backbone.View
 initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('relevance:app', @select_rel_app)
    @controller.bind('explore:app', @select_explore_app)
    @masterTabView = new Searchad.Views.MasterTab.IndexView(
        el: 'div.master-tab')

  events:
    'click li.relevance-tab': 'relevance'
    'click li.explore-tab': 'explore'
    
  toggleTab: (e) =>
    @$el.find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')

  relevance: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('relevance:app')
    @controller.trigger('search-rel:index')
    @router.update_path('search_rel')

  explore: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('explore:app')
    @controller.trigger('poor-performing-stats:index')
  
  select_rel_app: =>
    e = {}
    e.target = @$el.find('li.relevance-tab a').get(0)
    @toggleTab(e)

  select_explore_app: =>
    e = {}
    e.target = @$el.find('li.explore-tab a').get(0)
    @toggleTab(e)
