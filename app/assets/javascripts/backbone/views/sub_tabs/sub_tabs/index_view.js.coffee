Searchad.Views.SubTabs ||= {}

class Searchad.Views.SubTabs.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('search:sub-tab-cleanup', @unrender)
    @controller.bind('search:sub-content:show-spin', @show_spin)
    @controller.bind('search:sub-content:hide-spin', @hide_spin)
    @active = false
  
  data:
    query: null

  events:
    'click li.search-stats-tab': 'stats'
    'click li.search-amazon-items-tab': 'amazon_items'
    'click li.search-walmart-items-tab': 'walmart_items'
    'click li.rev-rel-tab': 'rev_rel'
    'click li.cvr-dropped-item-comparison-tab': 'show_cvr_dropped_item_comparison'

  template: JST['backbone/templates/poor_performing/search_sub_tabs']

  update_url: (path) =>
    if @data.query
      newPath = Utils.UpdateURLParam(window.location.hash, 'query',
        @data.query)
      @router.navigate(path + newPath)


  stats: (e) =>
    @toggleTab(e)
    @controller.trigger('search:stats', @data)
 
  walmart_items: (e) =>
    @toggleTab(e)
    @controller.trigger('search:walmart-items', @data)
  
  amazon_items: (e) =>
    @toggleTab(e)
    @controller.trigger('search:amazon-items', @data)

  rev_rel: (e) =>
    @toggleTab(e)
    @controller.trigger('search:rel-rev', @data)

  show_cvr_dropped_item_comparison:(e)=>
    @toggleTab(e)
    @controller.trigger('cvr_dropped_query:item_comparison',@data)

  toggleTab: (e) =>
    e.preventDefault()
    @$el.find('li.active').removeClass('active')
    $(e.target).parent().addClass('active')
    @controller.trigger('sub-content-cleanup')

  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @hide_spin()


  render: (data) =>
    @data = data
    @$el.prepend(@template()) unless @active
    @delegateEvents()
    @active = true
    
    if not (@$el.find('li.active').length > 0)
      # only show cvr_dropped_item_comparison on certain url specificaly 
      if @router.root_path_contains(/#adhoc_query\/mode\/query_comparison/)
        tab = @$el.find('li.cvr-dropped-item-comparison-tab').first()
        tab.show()
        tab.addClass('active')
      else if @router.root_path_contains(/#adhoc_query\/mode\/search/)
        @$el.find('li.cvr-dropped-item-comparison-tab').hide()
        tab = @$el.find('li.search-walmart-items-tab').first()
        tab.addClass('active')
      else if @router.root_path_contains(/#search_rel/)
        @$el.find('li.cvr-dropped-item-comparison-tab').hide()
        tab = @$el.find('li.search-amazon-items-tab').first()
        tab.addClass('active')
      else
        @$el.find('li.cvr-dropped-item-comparison-tab').hide()
        tab = @$el.find('li.search-stats-tab').first()
        tab.addClass('active')

    @$el.find('li.active a').first().click()
  
  show_spin: =>
    @$el.find('.ajax-loader').css('display', 'block')

  hide_spin: =>
    @$el.find('.ajax-loader').hide()
