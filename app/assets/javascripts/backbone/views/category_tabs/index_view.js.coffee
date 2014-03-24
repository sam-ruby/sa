Searchad.Views.CategoryTabs ||= {}

class Searchad.Views.CategoryTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    
    @listenTo(@router, 'route', (route, params) =>
      if route != 'category'
        @unrender()
        return

      if @router.task == 'ndcg'
        @ndcg()
    )

  events: =>
    'click li.ndcg-tab a': (e) =>
      e.preventDefault()
      @controller.trigger('content-cleanup')
      @router.update_path('/category/ndcg', trigger: true)
   
  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    $(el).parents('li').addClass('active')

  render: =>
    return unless @active
    @$el.css('display', 'block')
    @delegateEvents()

  unrender: =>
    @active = false
    @$el.hide()

  ndcg: (e, data) =>
    @active = true
    @render()
    @toggleTab(@$el.find('li.ndcg-tab a'))
