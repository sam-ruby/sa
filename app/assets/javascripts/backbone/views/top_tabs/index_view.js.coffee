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

  events:
    'click .login > .dropdown-menu > li > a': 'replace_login'

  replace_login: (e) =>
    e.preventDefault()
    user = $(e.target).text()
    if user?
      $(e.target).parents('.login').find(
        'div.logged-in-user').text(user)
   
  toggleTab: (el) =>
    @$el.find('.top-nav li.active').removeClass('active')
    $(el).parents('li').addClass('active')
