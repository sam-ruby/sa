class Searchad.Views.Base extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @active = false
    
    that = this
    class @SortedHeaderCell extends Backgrid.HeaderCell
      initialize: (options) ->
        super(options)
        @setCellDirection('descending')
        @$el.css('text-align', 'right')

    class @AscHeaderCell extends Backgrid.HeaderCell
      initialize: (options) ->
        super(options)
        @setCellDirection('ascending')
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
 
    class @PercentFormatter extends Backgrid.NumberFormatter
      fromRaw: (rawValue) ->
        return '-' unless rawValue?
        if !isNaN(parseFloat(rawValue))
          try
            "#{super(parseFloat(rawValue))}%"
          catch error
            console.log 'Here it is '
            "#{parseFloat(rawValue).toFixed(2)}%"
        else
          '-'
    
    class @OosCell extends Backgrid.NumberCell
      formatter: Utils.CustomNumberFormatter
      render: =>
        @$el.empty()
        val = parseFloat(@model.get(@column.get('name')))
        if !val? or isNaN(val)
          @$el.html('--')
          return this
       
        val_formatted = this.formatter.fromRaw(val)
        if val > 90
          class_name = 'badge-important'
          el = $(
            "<span class='badge #{class_name}'>#{val_formatted}%</span>")
        else
          el = $("<span>#{val_formatted}%</span>")
        @$el.append(el)
        this

    class @CadIntFormatter extends Backgrid.NumberFormatter
      fromRaw: (rawValue)->
        if !rawValue?
          '-'
        else if !isNaN(parseInt(rawValue))
          try
            super(parseInt(rawValue))
          catch error
            parseInt(rawValue)
        else
          '-'
          
      
