Searchad.Views.ConvCorrelation ||= {}
Searchad.Views.ConvCorrelation.Index ||= {}

class Searchad.Views.ConvCorrelation.Index extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    
    @listenTo(@router, 'route', (route, params) =>
      @$el.children().not('.ajax-loader').remove() if @active
      if route == 'search' and @router.sub_task == 'conv_cor'
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
    class ScoreHeaderCell extends Backgrid.HeaderCell
      initialize: (options) ->
        super(options)
        @direction('descending')
        @$el.css('text-align', 'right')

    class CountHeaderCell extends Backgrid.HeaderCell
      initialize: (options) ->
        super(options)
        @$el.css('text-align', 'right')


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
    headerCell: CountHeaderCell,
    cell: 'integer'},
    {name: 'score',
    label: "Conv Correlation Score",
    editable: false,
    sortType: 'toggle',
    headerCell: ScoreHeaderCell,
    cell: 'integer'}]

    columns
