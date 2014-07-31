Searchad.Views.EvalTabs ||= {}

class Searchad.Views.EvalTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    
    @listenTo(@router, 'route:eval', (path, filter) =>
      @$el.css('display', 'block')
      $('#eval').css('display', 'block')
      sub_tab = path.eval
      if sub_tab
        target = @$el.find("li.#{sub_tab} a")
        @toggleTab(target)
    )
    
    @listenTo(@router, 'route', (route, params) =>
      @unrender() if route != 'eval'
    )

  events:
    'click ul.nav li a': 'update_sub_tab'

  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    $(el).parents('li').addClass('active')

  unrender: =>
    @$el.hide()
    $('#eval').hide()
  
  update_sub_tab: (e) =>
    e.preventDefault()
    if e.target.nodeName.match(/SPAN/i)
      target = $(e.target).parent()
    else
      target = e.target
    @toggleTab(target)
    sub_tab_url = $(target).attr('href').replace(/#/, '')
    @router.update_path(sub_tab_url, trigger: true) if sub_tab_url
