#= require backbone/views/base
#
Searchad.Views.SubTabs ||= {}
Searchad.Views.SubTabs.RelRev ||= {}

class Searchad.Views.SubTabs.RelRev.IndexView extends Searchad.Views.Base
  initialize: (options) =>
    _.bindAll(this, 'render', 'initTable')
    @collection = new Searchad.Collections.QueryItemsCollection()
    @shadowCollection = @collection.clone()
    @shadowCollection.bind('reset', @render_result)
    @collection.bind('reset', @p_missed_items)
    super(options)
    
    @items = []
    @rel_item_template = JST["backbone/templates/rel_items_rec"]
    Utils.InitExportCsv(this, '/search_rel/get_query_items.csv')
    @div_container = $('<div>')
    @div_container.hide()
    @$el.append( @div_container )
    @initTable()
    
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @controller.bind('sub-content-cleanup', @unrender)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('request', =>
      @controller.trigger('search:sub-content:show-spin')
    )
    @undelegateEvents()
    @active = false

  events: =>
    'click input.missed-items': 'p_missed_items'
    'click a.item-uncheck': 'uncheck_items'
    'click .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      query = @query.replace(/\s+/g, '_')
      query = query.replace(/"|'/, '')
      fileName = "relevance_best_seller_#{query}_#{date}.csv"
      data =
        date: date
        query: @query
      @export_csv($(e.target), fileName, data)
    'click button.do-sig-comp': =>
       if @items.length == 0
         @$el.find('span.sig-comp-msg').fadeIn()
         @$el.find('span.sig-comp-msg').fadeOut(8000)
       else
         path = @router.path
         if path.search == 'adhoc'
           new_path = "search/adhoc/details/sig_comp/query/" +
             "#{encodeURIComponent(path.query)}/items/#{@items.join(',')}"
         else
           new_path = "search/#{path.search}/page/#{path.page}/details/" +
             "sig_comp/query/#{encodeURIComponent(path.query)}/items/" +
             "#{@items.join(',')}"
         @router.update_path(new_path, trigger: true)
    'click button.get-items': (e) =>
      engine_url = $(e.target).parents(
        'div.from-search-engines').find('select :selected').val()
      @show_realtime_items(engine_url)

  show_realtime_items: (engine_url)=>
    $.ajax(
      dataType: 'json'
      url: @controller.svc_base_url + '/engine_stats/get_query_items'
      data:
        engine: engine_url
        query: @query
      complete: (xhr) ->
        if xhr? and xhr.responseText?
          data = JSON.parse(xhr.responseText)
        else
          data = {}
        console.log 'Here is the data rxed ', data
    )


  uncheck_items: (e)=>
    e.preventDefault()
    @$el.find('table td input:checked').attr('checked', false)
    @$el.find('table td input:disabled').removeAttr('disabled')
    @items = []

  p_missed_items: (e)=>
    view = this
    if e? and e.target?
      target = $(e.target)
    else
      target = @$el.find('input:checkbox.missed-items')

    if target.length == 0 or target.is(':checked')
      @shadowCollection.reset(@collection.fullCollection.models)
    else
      @collection.fullCollection.where(in_top_16: 0).forEach((model) ->
        item_id = model.get('item_id')
        if (index = view.items.indexOf(item_id)) > -1
          view.items.splice(index, 1)
      )
      @shadowCollection.reset(@collection.fullCollection.where(in_top_16: 1))
  
  gridColumns: =>
    view = this
    class ItemCell extends Backgrid.Cell
      item_template:
        JST["backbone/templates/search_quality_query/query_items/item"]
      events: =>
        'click input:checkbox': (e) =>
          if $(e.target).is(':checked')
            view.items.push(@model.get('item_id'))
            if view.items.length >= 4
              view.$el.find('table input:checkbox').not(':checked').attr(
                'disabled', true)
          else
            item_id = @model.get('item_id')
            if (index = view.items.indexOf(item_id)) > -1
              view.items.splice(index, 1)
              if view.items.length < 4
                view.$el.find('table input:disabled').removeAttr('disabled')
      render: =>
        @$el.empty()
        formatted_value = @item_template(
          image_url: @model.get('image_url')
          item_id: @model.get('item_id')
          title: @model.get('title'))

        input_box = $('<label class="checkbox signal-comp">' +
          '<input type="checkbox"/></label>')
        if @model.get('item_id') in view.items
          input_box.find('input').attr('checked', true)
        else if view.items.length >= 4
          input_box.find('input').attr('disabled', true)
        
        @$el.append(input_box)
        @$el.append(formatted_value)
        @delegateEvents()
        this

    class MyIntegerCell extends Backgrid.IntegerCell
      render: =>
        if parseInt(@model.get('in_top_16')) == 1
          val = @model.get(@column.get('name'))
          if val > 0
            @$el.html('<span class="badge badge-success green-order">' +
              val + '</span>')
          else
            @$el.html('<span class="badge badge-warning red-order">' +
              val + '</span>')
        else
          super()
        this

    class MyPosition extends Backgrid.IntegerCell
      render: =>
        @$el.addClass('recom-item-position')
        if @model.get('in_top_16') == 1
          super()
          this
        else
          @$el.html('<span class="label label-important">Recommended Item</span>')
          this

    class OrdersHeaderCell extends @NumericHeaderCell
      events:
        'click a': 'onClick'
      
      onClick: (e)=>
        e.preventDefault()
        columnName = this.column.get("name")
        if (@column.get("sortable"))
          if @column.get('direction') == "descending"
            view.grid.sort(columnName, "ascending", (left, right) ->
              leftVal = left.get(columnName)
              rightVal = right.get(columnName)
              if (leftVal == rightVal)
                0
              else if (leftVal > rightVal)
                -1
              else
                1
            )
          else if @column.get('direction') == "ascending"
            view.grid.sort(columnName, null)
          else
            view.grid.sort(columnName, "descending", (left, right)->
              leftVal = left.get(columnName)
              rightVal = right.get(columnName)
              if (leftVal == rightVal)
                0
              else if (leftVal < rightVal)
                -1
              else
                1
            )
    
    columns = [{
    name: 'position',
    label: 'Position',
    headerCell: @NumericHeaderCell,
    editable: false,
    formatter: Utils.CustomNumberFormatterNoDecimals,
    cell: MyPosition},
    {name: 'item',
    label: 'Item',
    editable: false,
    sortable: false,
    cell: ItemCell},
    {name: 'orders',
    label: 'Order Count',
    headerCell: OrdersHeaderCell,
    editable: false,
    cell: MyIntegerCell}]
    columns

  initTable: =>
    class RecommendedRow extends Backgrid.Row
      render: =>
        if @model.get('in_top_16') == 0
          @$el.addClass('recommended-item')
        super()
        this
    
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @shadowCollection
      emptyText: 'No Data'
      className: 'rel-rev-grid'
      row: RecommendedRow
    )

    view = this
    @addToDom = (data) ->
      view.div_container.append(view.rel_item_template(
        engine_names: data.engine_names
        engine_name_url_map: data.engine_name_url_map))
      view.div_container.append(view.grid.render().$el)
      view.div_container.append(view.export_csv_button())

    $.ajax(
      dataType: 'json'
      url: @controller.svc_base_url + '/engine_stats/get_engines'
      complete: (xhr) ->
        if xhr? and xhr.responseText?
          data = JSON.parse(xhr.responseText)
          engine_names = _.keys(data).sort()
        else
          data = {}
          engine_names = []
        view.addToDom(
          engine_names: engine_names
          engine_name_url_map: data)
    )
    
  get_items: (data) =>
    @active = true
    data || = { }
    if data.query
      @query = data.query
    else
      data.query = @query
    data.view || = "daily"
    @collection.get_items(data)

  render_error: (query) ->
    return unless @active
    
    @controller.trigger('search:sub-content:hide-spin')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )

  render_result: =>
    return unless @active
    rec_flag = @collection.fullCollection.where(in_top_16: 0).length > 0
    recommended_div = @div_container.find('div.recommended-holder')
    if !rec_flag
      recommended_div.empty()
      recommended_div.append('<span style="padding-top:10px">' +
        'No Recommendations with Significant Evidence</span>')
    else if recommended_div.find('input.missed-items').length == 0
      recommended_div.empty()
      recommended_div.append('<label class="show-rec-items checkbox">' +
        '<input class="missed-items" type="checkbox" checked/>' +
        'Show Recommended Items</label>')

    @controller.trigger('search:sub-content:hide-spin')
    @delegateEvents()
    return this

  render: (data)=>
    @items = []
    @div_container.show()
    @grid.render()
    if @div_container.parents().length == 0
      @$el.append(@div_container)
    @get_items(data)
      
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @items = []
    @controller.trigger('search:sub-content:hide-spin')
    @undelegateEvents()
