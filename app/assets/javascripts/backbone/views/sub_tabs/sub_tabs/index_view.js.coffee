Searchad.Views.SubTabs ||= {}

class Searchad.Views.SubTabs.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('search:sub-tab-cleanup', @unrender)
    @query_stats_template = JST['backbone/templates/query_stats']
    @queryStatsCollection =
      new Searchad.Collections.QueryStatsDailyCollection()
    @queryStatsCollection.bind('reset', @render_query_info)
    @queryStatsCollection.bind('request', =>
      @controller.trigger('sub-content-cleanup')
      @controller.trigger('search:sub-tab-cleanup')
      @show_spin()
    )

    @listenTo(@controller, 'search:sub-content:hide-spin', =>
      @hide_sub_content_spin()
    )
    
    @listenTo(@controller, 'search:sub-content:show-spin', =>
      @show_sub_content_spin()
    )

    @listenTo(@router, 'route:search', (path, filter) =>
      if @router.date_changed or @router.cat_changed or @router.query_segment_changed or path.query != @query
        @query = path.query
        if parseInt(path.details) == 1 and path.query?
          if path.search? and (match = path.search.match(/drop_con_(\d+)/))
            weeks_apart = match[1]
          feature = path.page
          
          show_series = ['query_count', 'query_con']
          if feature == 'pvr'
            show_series.push('query_pvr')
          else if feature == 'atc'
            show_series.push('query_atc')

          @data =
            weeks_apart: weeks_apart
            query: @query
            show_only_series: show_series
          @queryStatsCollection.query = @query
          @queryStatsCollection.get_items()

        else if path.search == 'adhoc' and path.query?
          @data =
            search: true
            query: @query
          @queryStatsCollection.query = @query
          @queryStatsCollection.get_items()
          $('form.form-search input:text').val(@query)
    )
    
    $('form.form-search button.search').on('click', (e)=>
      e.preventDefault()
      search = $(e.target.form).find('input:text').val()
      if search?
        @router.update_path('search/adhoc/query/' +  encodeURIComponent(search),
          trigger: true)
    )
  
  render_query_info: =>
    @hide_spin()
    @$el.children().not('.ajax-loader').remove()
    metric = @queryStatsCollection.toJSON()[0]
    @$el.append(@query_stats_template(
      metric: metric
      query: @query))
    @render() if metric?

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
    @controller.trigger('cvr_dropped_query:item_comparison', @data)

  toggleTab: (e) =>
    e.preventDefault()
    @$el.find('li.active').removeClass('active')
    $(e.target).parents('li').addClass('active')
    @controller.trigger('sub-content-cleanup')

  unrender: =>
    @$el.children().not('.ajax-loader').remove()
    @hide_spin()

  render: =>
    @$el.append(@template)
    @delegateEvents()
    
    if not (@$el.find('li.active').length > 0)
      # only show cvr_dropped_item_comparison on certain url specificaly 
      @$el.find('li.cvr-dropped-item-comparison-tab').hide()

      # If coming from search, show the Walmart Results
      if @data.search
        tab = @$el.find('li.search-walmart-items-tab').first()
        tab.addClass('active')
      else
        if @router.path? and @router.path.search?
          segment = @router.path.search
        if @router.path? and @router.path.page?
          feature = @router.path.page

        if feature and feature.match(/^o_/)
            tab = @$el.find('li.rev-rel-tab').first()
            tab.addClass('active')
        else if segment and segment.match(/drop_con/i)
          tab = @$el.find('li.cvr-dropped-item-comparison-tab')
          tab.show()
          tab.addClass('active')
        else if segment and segment.match(/poor_amzn/)
          tab = @$el.find('li.search-amazon-items-tab').first()
          tab.addClass('active')
        else if segment and segment.match(/(trend_\d+)|(poor_perform)/)
          tab = @$el.find('li.search-walmart-items-tab').first()
          tab.addClass('active')
        else
          tab = @$el.find('li.search-stats-tab')
          tab.addClass('active')

    @$el.find('li.active a').first().click()
  
  show_spin: =>
    @$el.find('.ajax-loader').css('display', 'block')

  hide_spin: =>
    @$el.find('.ajax-loader').hide()
    
  show_sub_content_spin: =>
    @$el.find('.second-navbar img.ajax-loader').css('display', 'block')

  hide_sub_content_spin: =>
    @$el.find('.second-navbar img.ajax-loader').hide()
