Searchad.Views.SearchQualityQuery.SubTabs ||= {}

class Searchad.Views.SearchQualityQuery.SubTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('search:sub-content-cleanup', @unrender)
    @controller.bind('search:query-items:index',
      @select_first_tab)
 
  events:
    'click': 'pre_render'

  template: JST["backbone/templates/search_quality_query/query_items/tabs"]
  
  pre_render: (e) =>
    e.preventDefault()
    @controller.trigger('search:sub-content-cleanup')

  select_first_tab: =>
    unless @$el.find('ul.nav').length > 0
      @$el.append( @template())
    @$el.find('li.active').removeClass('active')
    @$el.find('li' + '.query-items-tab').addClass('active')
  
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
