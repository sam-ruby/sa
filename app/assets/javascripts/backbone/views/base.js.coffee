class Searchad.Views.Base extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @active = false
    
    that = this
    class @RateCell extends Backgrid.Cell
      events:
        'click i.icon-thumbs-up': 'rate'
        'click i.icon-thumbs-down': 'rate'

      rate: (e)=>
        view = this
        e.preventDefault()
        span = $(e.target).parents('span')
        td  = $(e.target).parents('td')
        
        if $(e.target).hasClass('icon-thumbs-up')
          rate = 1
          class_name = 'green-rate'
        else if $(e.target).hasClass('icon-thumbs-down')
          rate = 0
          class_name ='red-rate'

        if td.hasClass(class_name)
          rate = -1
          td.removeClass(class_name)
        else
          td.removeClass('green-rate red-rate')
          td.addClass(class_name)

        $.ajax(that.controller.svc_base_url + '/prefs/record_rating',
          data:
            rate: rate
            query: @model.get('query')
            user_id: that.controller.user_id
            metric_name: 'all'
          dataType: 'json'
          success: (data, status)->
            span.tooltip('show')
          error: (jqXhr, status)->
            span.tooltip('show')
        )

      render: =>
        @$el.empty()
        rating = @model.get('rating')
        if rating == 1
          class_name = 'green-rate'
        else if rating == 0
          class_name = 'red-rate'
        
        @$el.append("<span class='rate-up' data-toggle='tooltip' " +
          "data-animation='true' data-title='Feedback Recorded!'>" +
          "<i class='icon-thumbs-up'></i></span>" +
          "<span class='rate-down' data-toggle='tooltip' " +
          "data-animation='true' data-title='Feedback Recorded!'>" +
          "<i class='icon-thumbs-down'></i></span>")
        @$el.addClass(class_name)
        this

    class @RateHeaderCell extends Backgrid.HeaderCell
      initialize: (options) ->
        super(options)
        @template = JST['backbone/templates/rate_header']

      events:
        'click a.filter-all': 'show_all'
        'click a.filter-exclude-bad': 'exclude_bad'
        'click a.filter-only-good': 'only_good'

      show_all: (e)=>
        e.preventDefault()
        that.collection.get_items(
          user_id: that.controller.user_id
        )

      exclude_bad: (e)=>
        e.preventDefault()
        that.collection.get_items(
          filter_by: 'rating'
          filter_cond: 'with_good'
          user_id: that.controller.user_id
        )

      only_good: (e)=>
        e.preventDefault()
        that.collection.get_items(
          filter_by: 'rating'
          filter_cond: 'only_good'
          user_id: that.controller.user_id
        )
      
      render: =>
        super()
        @$el.prepend(@template())
        this

    class @SortedHeaderCell extends Backgrid.HeaderCell
      initialize: (options) ->
        super(options)
        @setCellDirection(@column, 'descending')
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
          
      
