Searchad.Views.SearchQualityQuery.SubTabs ||= {}

class Searchad.Views.SearchQualityQuery.SubTabs.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('search-rel:sub-content-cleanup', @unrender)
    @controller.bind('search-rel:query-items:index',
      @select_first_tab)
    @controller.bind('search-rel:query-items:set-tab-content',
      @set_tab_content)
 
  events:
    'click': 'pre_render'

  template: JST["backbone/templates/search_quality_query/query_items/tabs"]
  
  pre_render: (e) =>
    e.preventDefault()
    @controller.trigger('search-rel:sub-content-cleanup')

  select_first_tab: =>
    unless @$el.find('ul.nav').length > 0
      @$el.append(@template())
    @$el.find('li.active').removeClass('active')
    @$el.find('li' + '.query-items-tab').addClass('active')
  
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()

  set_tab_content: (query) =>
    @$el.find('i.tab-query').text(query)
