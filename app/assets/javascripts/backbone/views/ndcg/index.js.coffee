Searchad.Views.NDCG ||= {}
Searchad.Views.NDCG.Index ||= {}

class Searchad.Views.NDCG.Index extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @controller.bind('content-cleanup', @unrender)
    @router = SearchQualityApp.Router
    
    @listenTo(@router, 'route', (route, params) =>
      @$el.children().not('.ajax-loader').remove() if @active
      if route == 'search' and @router.sub_task == 'ndcg'
        @$el.children().not('.ajax-loader').remove()
        @get_items(@router.sub_task)
      else
        @active = false
    )
    active: false

  prepare_for_render: =>
    @$el.append(
      $('<img class="ajax-loader" src="/assets/ajax_loader.gif">').css(
        'display', 'block') )

  unrender: =>
    @active = false
    
  gridColumns: ->
    that = this
    class QueryCell extends Backgrid.CADQueryCell
      handleQueryClick: (e) ->
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = @model.get('query')
        that.controller.trigger('search:sub-content',
          query: query
          view: 'daily'
        )
        new_path = 'search_rel/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)
        false
    
    columns = [{
    name: 'query',
    label: I18n.t('search_analytics.query_string'),
    editable: false,
    cell: QueryCell},
    {name: 'count',
    label: I18n.t('search_analytics.query_count'),
    editable: false,
    cell: 'integer'},
    {name: 'ndcg',
    label: "NDCG",
    editable: false,
    cell: 'number'}]

    columns
