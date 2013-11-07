Searchad.Views.Search ||= {}

class Searchad.Views.Search.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    
    @$search_results = $(options.el_results)
    @controller.bind('content-cleanup', @unrender)
    
    @queryStatsCollection = new Searchad.Collections.QueryStatsDailyCollection()
    @queryStatsCollection.bind('reset', @render_search_results)
  
  data:
    query: null

  events:
    'submit': 'do_search'
    'click button.search-btn': 'do_search'

  search_form_template: JST['backbone/templates/search/form']

  update_url: (path) =>
    if @data.query
      newPath = Utils.UpdateURLParam(window.location.hash, 'query',
        @data.query)
      @router.navigate(path + newPath)

  do_search: (e) =>
    e.preventDefault()
    @search_results_cleanup()
    @controller.trigger('sub-content-cleanup')
    @search_term = @$el.find('input.search-query').val()
    @router.update_path('search/query/' + encodeURIComponent(@search_term))
    
    @queryStatsCollection.get_items(query: @search_term)
    @trigger = true

  unrender: =>
    @active = false
    @$el.children().remove()
    @$search_results.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()

  render: =>
    @active = true
    @$el.append(@search_form_template())
    @delegateEvents()

  search_results_cleanup: =>
    @$search_results.children().remove()

  query_cell: ->
    that = this
    class QueryCell extends Backgrid.Cell
      controller: SearchQualityApp.Controller
      events:
        'click': 'handleQueryClick'
      handleQueryClick: (e) =>
        e.preventDefault()
        $(e.target).parents('table').find('tr.selected').removeClass('selected')
        $(e.target).parents('tr').addClass('selected')
        that.controller.trigger('sub-content-cleanup')
        that.query = $(e.target).text()
        that.controller.trigger('search:stats', query: that.query)
      render: ->
        value = @model.get(@column.get('name'))
        formatted_value = '<a class="query" href="#">' + value + '</a>'
        @$el.html(formatted_value)
        @delegateEvents()
        return this

    return QueryCell

  render_search_results: =>
    @search_results_cleanup()
    if @queryStatsCollection.length == 0
      @$search_results.append(
        '<p class="text-error">No data available for "' +
        @search_term + '"')
      return

    paginator = new Backgrid.Extension.Paginator(
      collection: @queryStatsCollection
    )
    grid = new Backgrid.Grid(
      columns: [{
        name: 'query'
        label: 'Query'
        editable: false
        cell: @query_cell()},
        {name: 'query_count'
        label: 'Query Count'
        editable: false
        cell: 'number'},
        {name: 'query_pvr'
        label: 'Query PVR'
        editable: false
        cell: 'number'},
        {name: 'query_atc'
        label: 'Query ATC'
        editable: false
        cell: 'number'},
        {name: 'query_con'
        label: 'Query Conversion Rate'
        editable: false
        cell: 'number'},
        {name: 'query_revenue'
        label: 'Query Revenue'
        editable: false
        cell: 'number'}]
      collection: @queryStatsCollection)
    
    @$search_results.append($('<div>').css('text-align', 'left').css(
      'margin-bottom': '1em').append(
      $('<i>').addClass('icon-search').css(
        'font-size', 'large').append(
        '&nbsp; Results for : ' + @search_term)))
    @$search_results.append( grid.render().$el )
    @$search_results.append( paginator.render().$el )
    if @trigger
      @trigger = false
      @$search_results.find('td a.query').first().trigger('click')
