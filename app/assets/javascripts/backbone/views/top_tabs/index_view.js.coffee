Searchad.Views.TopTabs ||= {}

class Searchad.Views.TopTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
 
    @listenTo(@router, 'route', (route, params) =>
      @$el.find('li.active').removeClass('active')
      if route == 'search'
        @toggleTab(@$el.find('.search-tab a'))
      else if route == 'browse'
        @toggleTab(@$el.find('.browse-tab a'))
      else if route == 'category'
        @toggleTab(@$el.find('.category-tab a'))
    )
   
  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    $(el).parents('li').addClass('active')
