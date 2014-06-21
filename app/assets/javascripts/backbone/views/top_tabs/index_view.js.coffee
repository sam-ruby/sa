Searchad.Views.TopTabs ||= {}

class Searchad.Views.TopTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @updateLoginUser()
    @updateLogoutLink()
 
    @listenTo(@router, 'route', (route, params) =>
      @$el.find('li.active').removeClass('active')
      if route == 'search'
        @toggleTab(@$el.find('.search-tab a'))
      else if route == 'browse'
        @toggleTab(@$el.find('.browse-tab a'))
      else if route == 'category'
        @toggleTab(@$el.find('.category-tab a'))
      else if route == 'ab_tests'
        @toggleTab(@$el.find('.ab-tests-tab a'))
    )

  replace_login: (e) =>
    e.preventDefault()
    user = $(e.target).text()
    if user?
      $(e.target).parents('.login').find(
        'div.logged-in-user').text(user)
   
  toggleTab: (el) =>
    @$el.find('.top-nav li.active').removeClass('active')
    $(el).parents('li').addClass('active')

  updateLoginUser: =>
    that = this
    MDW.getLoginStatus((session) ->
      if session
        currentUser = session.username
        that.$el.find('div.logged-in-user').text(currentUser)
    )

  updateLogoutLink: =>
    logoutUrl = MDW._domain.www + '/users/logout'
    @$el.find('a.logout').attr('href', logoutUrl)
