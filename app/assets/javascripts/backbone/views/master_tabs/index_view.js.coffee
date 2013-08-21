Searchad.Views.MasterTab ||= {}

class Searchad.Views.MasterTab.IndexView extends Backbone.View
 initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('poor-performing:index', @select_pp_tab)
    @controller.bind('search-quality-query:index', @select_sq_tab)
    @widget_el =  @$el.find('.modal')
    @widget_el.modal(
      backdrop: false
      show: false
      keyboard: true
    )
  
  events:
    'click .add-widget': 'openWidgetDialog'
    'click a.cancel-widget': 'cancelWidgetDialog'
    'click a.save-widget': 'saveWidget'
    'click li.search-quality-tab': 'searchQuality'
    'click li.poor-performing-tab': 'poorPerforming'
    'click .dashboard-tab': 'dashBoard'
    
  toggleTab: (e) =>
    if $(e.target).hasClass('dashboard-tab')
      @$el.find('div.dashboard-tab').hide()
      @$el.find('div.add-widget').show()
    else
      @$el.find('div.dashboard-tab').show()
      @$el.find('div.add-widget').hide()
    
    @$el.find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')

  searchQuality: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('search-quality-query:index')
    @router.update_path('search')

  poorPerforming: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('poor-performing:index')
    @router.update_path('poor_performing')

  dashBoard: (e) =>
    @controller.trigger('content-cleanup')
    e.preventDefault()
    @controller.trigger('dashboard:index')
    @router.update_path('/')
  
  select_pp_tab: =>
    e = {}
    e.target = @$el.find('li.poor-performing-tab a').get(0)
    @toggleTab(e)
 
  select_sq_tab: =>
    e = {}
    e.target = @$el.find('li.search-quality-tab a').get(0)
    @toggleTab(e)
    
  saveWidget: =>
    $('#main-content .modal', @el).modal('hide')
    # Trigger additional widgets from here.

  openWidgetDialog: =>
    @widget_el.modal('show')

  cancelWidgetDialog: =>
    @widget_el.modal('hide')


