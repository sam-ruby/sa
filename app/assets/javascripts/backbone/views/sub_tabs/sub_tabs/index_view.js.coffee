Searchad.Views.SubTabs ||= {}

class Searchad.Views.SubTabs.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('search:sub-tab-cleanup', @unrender)
    @controller.bind('search:sub-content:show-spin', @show_spin)
    @controller.bind('search:sub-content:hide-spin', @hide_spin)
    @user_tabs = Searchad.UserLatest.SubTab
    @active = false
  
  data:
    query: null

  events:
    'click li.search-stats-tab': 'stats'
    'click li.search-amazon-items-tab': 'amazon_items'
    'click li.search-walmart-items-tab': 'walmart_items'
    'click li.rev-rel-tab': 'rev_rel'
    'click li.cvr-dropped-item-comparison-tab': 'show_cvr_dropped_item_comparison' # .cvr-dropped-item-comparison

  template: JST['backbone/templates/poor_performing/search_sub_tabs']

  update_url: (path) =>
    if @data.query
      newPath = Utils.UpdateURLParam(window.location.hash, 'query',
        @data.query)
      @router.navigate(path + newPath)


  stats: (e) =>
    @toggleTab(e)
    @controller.trigger('search:stats', @data)
    # change user latest click tab to store stats, so when user stwitch between queries, 
    # the tab won't jump from one to anoter
    @user_tabs.update_selected_tab("stats")
 

  walmart_items: (e) =>
    @toggleTab(e)
    @controller.trigger('search:walmart-items', @data)
    @user_tabs.update_selected_tab("walmart")
  
  
  amazon_items: (e) =>
    @toggleTab(e)
    @controller.trigger('search:amazon-items', @data)
    @user_tabs.update_selected_tab("amazon")


  rev_rel: (e) =>
    @toggleTab(e)
    @controller.trigger('search:rel-rev', @data)
    @user_tabs.update_selected_tab("rel-rev-analysis")

  show_cvr_dropped_item_comparison:(e)=>
    @toggleTab(e)
    @controller.trigger('cvr_dropped_query:item_comparison',@data)
    @user_tabs.update_selected_tab("cvr-dropped-item-comparison")


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
    @data = data;
    @$el.prepend(@template()) unless @active
    @delegateEvents()
    @active = true 
    curr_tab = @user_tabs.current_tab
    # only show cvr_dropped_item_comparison on certain url specificaly adhoc query
    if @router.get_root_path()== "#adhoc_query"
      @$el.find('li.cvr-dropped-item-comparison-tab').show()
      # toggle the subtabs
      if @user_tabs.cvr_item_tab_selected
        @$el.find('li.cvr-dropped-item-comparison-tab a').first().click()  
        return
    else
      @$el.find('li.cvr-dropped-item-comparison-tab').hide()

    if curr_tab == 'rel-rev-analysis'
      @$el.find('li.rev-rel-tab a').first().click()
    else if curr_tab == 'amazon'
      @$el.find('li.search-amazon-items-tab a').first().click()
    else if curr_tab == 'walmart'
      @$el.find('li.search-walmart-items-tab a').first().click()
    else
      @$el.find('li.search-stats-tab').first().click()


  show_spin: =>
    @$el.find('.ajax-loader').css('display', 'block')
  

  hide_spin: =>
    @$el.find('.ajax-loader').hide()
