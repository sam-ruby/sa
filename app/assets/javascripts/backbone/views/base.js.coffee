class Searchad.Views.Base extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    
    that = this
    class @SortedHeaderCell extends Backgrid.HeaderCell
      initialize: (options) ->
        super(options)
        @direction('descending')
        @$el.css('text-align', 'right')

    class @NumericHeaderCell extends Backgrid.HeaderCell
      initialize: (options) ->
        super(options)
        @$el.css('text-align', 'right')

    class @QueryHeaderCell extends Backgrid.HeaderCell
      initialize: (options) ->
        super(options)
        @$el.css('width', '30%')

    class @QueryCell extends Backgrid.CADQueryCell
      handleQueryClick: (e) ->
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = @model.get('query')
        that.controller.trigger('search:sub-content',
          query: query
          view: 'daily'
        )
        # new_path = 'search_rel/query/' + encodeURIComponent(query)
        # that.router.update_path(new_path)
        false
        
    class @PercentCell extends Backgrid.NumberCell
      render: =>
        @$el.empty()
        val = super(@model.get(@column.get('name'))).$el.text()
        @$el.html( val + '%' )
        this
