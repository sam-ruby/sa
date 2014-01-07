Searchad.Views.QueryMonitoring ||= {}
Searchad.Views.QueryMonitoring.SubTabs ||= {}

class Searchad.Views.QueryMonitoring.SubTabs.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('qm:sub-tab-cleanup', @unrender)
    @controller.bind('qm:sub-content:show-spin', @show_spin)
    @controller.bind('qm:sub-content:hide-spin', @hide_spin)
    @active = false
  
  data:
    query: null

  events:
    'click li.qm-count-stats-tab': 'count_stats'
    'click li.qm-metrics-stats-tab': 'metrics_stats'

  template: JST['backbone/templates/query_monitoring/sub_tabs']

  update_url: (path) =>
    if @data.query
      newPath = Utils.UpdateURLParam(window.location.hash, 'query',
        @data.query)
      @router.navigate(path + newPath)


  count_stats: (e) =>
    e.preventDefault()
    @controller.trigger('qm:sub-content:cleanup')
    @toggleTab(@$el.find('li.qm-count-stats-tab a'))
    @controller.trigger('qm-count:stats', query: @query)


  metrics_stats: (e) =>
    e.preventDefault()
    @controller.trigger('qm:sub-content:cleanup')
    @toggleTab(@$el.find('li.qm-metrics-stats-tab a'))
    @controller.trigger('qm-metrics:stats', query: @query)
  

  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @hide_spin()


  render: (data) =>
    @query = data.query if data.query
    @view = data.view if data.view
    @$el.prepend(@template()) unless @active
    @active = true
    @delegateEvents()
    if data.tab == 'count'
      @$el.find('li.qm-count-stats-tab').first().trigger('click')
      return
    if data.tab == 'metrics'
      @$el.find('li.qm-metrics-stats-tab').first().trigger('click')
      return


  toggleTab: (el) =>
    @$el.find('li.active').removeClass('active')
    el.parents('li').addClass('active')


  show_spin: =>
    @$el.find('.ajax-loader').css('display', 'block')
  

  hide_spin: =>
    @$el.find('.ajax-loader').hide()
