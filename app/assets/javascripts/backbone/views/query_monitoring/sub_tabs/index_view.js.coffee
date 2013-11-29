Searchad.Views.QueryMonitoring ||= {}
Searchad.Views.QueryMonitoring.SubTabs ||= {}

class Searchad.Views.QueryMonitoring.SubTabs.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('qm-count:sub-tab-cleanup', @unrender)
    @controller.bind('qm-count:sub-content:show-spin', @show_spin)
    @controller.bind('qm-count:sub-content:hide-spin', @hide_spin)
    @active = false
  
  data:
    query: null

  events:
    'click li.qm-count-stats-tab': 'stats'

  template: JST['backbone/templates/query_monitoring/sub_tabs']

  update_url: (path) =>
    if @data.query
      newPath = Utils.UpdateURLParam(window.location.hash, 'query',
        @data.query)
      @router.navigate(path + newPath)

  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    el.parents('li').addClass('active')

  stats: (e) =>
    e.preventDefault()
    @controller.trigger('qm-count:sub-content:cleanup')
    @toggleTab(@$el.find('li.qm-count-stats-tab a'))
    @controller.trigger('qm-count:stats', query: @query)
  
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @hide_spin()

  render: (data) =>
    @query = data.query if data.query
    @view = data.view if data.view
    @$el.prepend(@template()) unless @active
    @delegateEvents()
    
    if data.tab == 'stats'
      @$el.find('li.qm-count-stats-tab').first().trigger('click')
    else
      @$el.find('li.qm-count-stats-tab').first().trigger('click')
    @active = true

  show_spin: =>
    @$el.find('.ajax-loader').css('display', 'block')
  
  hide_spin: =>
    @$el.find('.ajax-loader').hide()
