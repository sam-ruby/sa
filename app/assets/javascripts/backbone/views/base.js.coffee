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

    class @MetricCell extends Backgrid.IntegerCell
      initialize: (options) ->
        super(options)
        @percent_cell = new Backgrid.PercentCell(
          column: @column
          model: @model)
        @number_cell = new Backgrid.NumberCell(
          decimals: 4
          column: @column
          model: @model)
      
      controller: SearchQualityApp.Controller
      router: SearchQualityApp.Router
      render: ->
        if @router.path? and @router.path.page == 'qrr'
          @percent_cell.render()
        else if @router.path? and @router.path.page == 'mrr'
          @number_cell.render()
        else
          super()

    class @CADQueryCell extends Backgrid.Cell
      initialize: (options) ->
        super
      controller: SearchQualityApp.Controller
      router: SearchQualityApp.Router
      
      events:
        'click a.query': 'handleQueryClick'
      
      handleQueryClick: (e) =>
        e.preventDefault()
        $(e.target).parents('table').find('tr.selected').removeClass('selected')
        $(e.target).parents('tr').addClass('selected')
      
      render: ->
        value = @model.get(@column.get('name'))
        formatted_value = '<span class="pull-right">' +
          '<a href="http://www.walmart.com/search/search-ng.do?search_query=' +
          encodeURIComponent(value) + '" target="_blank">' +
          '<img src="/assets/walmart-transparent.png" class="walmart-icon"></a>' +
          '<a href="http://www.amazon.com/s?url=search-alias%3Daps&field-keywords=' +
          encodeURIComponent(value) + '" target="_blank">' +
          '<img src="/assets/amazon-icon.jpeg" class="amazon-icon"></a>' +
          '</span><a class="query" href="#">' + value + '</a>'
        @$el.html(formatted_value)
        @delegateEvents()
        return this
    
    class @QueryCell extends @CADQueryCell
      events: =>
        events = that.CADQueryCell.prototype.events
        events['click a.query-reform'] = 'handleQueryReformulations'
        events
        
      handleQueryReformulations: (e) ->
        e.preventDefault()
        QueryCell.__super__.handleQueryClick.apply(this, arguments)
        query = @model.get(@column.get('name'))
        that.show_query()
        segment = (that.router.path? and that.router.path.search) || 'top'
        feature = (that.router.path? and that.router.path.page) || 'traffic'
        new_path = "search/#{segment}/page/#{feature}/details/query_reform/" +
          'query/' + encodeURIComponent(query)
        that.router.update_path(new_path, trigger: true)

      handleQueryClick: (e) ->
        e.preventDefault()
        super(e)
        query = @model.get('query')
        that.show_query()
        segment = (that.router.path? and that.router.path.search) || 'top'
        feature = (that.router.path? and that.router.path.page) || 'traffic'
        new_path = "search/#{segment}/page/#{feature}/details/1/query/" +
          encodeURIComponent(query)
        that.router.update_path(new_path, trigger: true)
 
      render: =>
        value = @model.get(@column.get('name'))
        if @router.path? and @router.path.page == 'qrr' and @router.path.details != 'query_reform'
          formatted_value = '<span class="pull-right">' +
            '<a href="#" class="query-reform">Reform..</a>' +
            '<a href="http://www.walmart.com/search/search-ng.do?search_query=' +
            encodeURIComponent(value) + '" target="_blank">' +
            '<img src="/assets/walmart-transparent.png" class="walmart-icon"></a>' +
            '<a href="http://www.amazon.com/s?url=search-alias%3Daps&field-keywords=' +
            encodeURIComponent(value) + '" target="_blank">' +
            '<img src="/assets/amazon-icon.jpeg" class="amazon-icon"></a>' +
            '</span><a class="query" href="#">' + value + '</a>'
          @$el.html(formatted_value)
          @delegateEvents()
        else
          super()
        this

    class @PercentFormatter extends Backgrid.NumberFormatter
      fromRaw: (rawValue) ->
        return '-' unless rawValue?
        if !isNaN(parseFloat(rawValue))
          try
            "#{super(parseFloat(rawValue))}%"
          catch error
            "#{parseFloat(rawValue).toFixed(2)}%"
        else
          '-'
    
    class @OosCell extends Backgrid.NumberCell
      formatter: Utils.CustomNumberFormatter
      render: =>
        @$el.empty()
        in_store = (@model.get('is_SOI') == 1)
        val = parseFloat(@model.get(@column.get('name')))
        if !val? or isNaN(val)
          @$el.html('--')
        else
          val_formatted = this.formatter.fromRaw(val)
          if in_store
            el = $('<span class="badge">In Store</span>')
          else if val > 90
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
          
      
