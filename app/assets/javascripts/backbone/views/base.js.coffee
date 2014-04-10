class Searchad.Views.Base extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @active = false
    
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
        e.preventDefault()
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = @model.get('query')
        that.show_query()
        segment = (that.router.path? and that.router.path.search) || 'top'
        feature = (that.router.path? and that.router.path.page) || 'traffic'
        new_path = "search/#{segment}/page/#{feature}/details/1/query/" +
          encodeURIComponent(query)
        that.router.update_path(new_path, trigger: true)
        
    class @PercentCell extends Backgrid.NumberCell
      render: =>
        @$el.empty()
        val = super(@model.get(@column.get('name'))).$el.text()
        @$el.html( val + '%' )
        this
