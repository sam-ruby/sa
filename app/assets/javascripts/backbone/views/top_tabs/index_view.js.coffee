Searchad.Views.TopTabs ||= {}

class Searchad.Views.TopTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
 
    @listenTo(@router, 'route', (route, params) =>
      @$el.find('li.active').removeClass('active')
      if route == 'search'
        @$el.find('li.search-tab').addClass('active')
      else if route == 'browse'
        @$el.find('li.browse-tab').addClass('active')
      else if route == 'category'
        @$el.find('li.category-tab').addClass('active')

    )
   
  events: =>
    'click li.search-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('content-cleanup')
      @router.update_path('/search/performance/poor_performing',
        trigger: true)

    'click li.browse-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('content-cleanup')
      @router.update_path('/browse', trigger: true)

    'click li.category-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('content-cleanup')
      @router.update_path('/category', trigger: true)
   
  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    $(el).parents('li').addClass('active')

  search: =>
    @toggleTab(@$el.find('.search-tab a'))

  browse: =>
    @toggleTab(@$el.find('.browse-tab a'))
  
  category: (e, data) =>
    @toggleTab(@$el.find('.category-tab a'))


