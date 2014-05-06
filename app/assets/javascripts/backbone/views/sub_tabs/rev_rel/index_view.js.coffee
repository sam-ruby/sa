#= require backbone/views/base
#
Searchad.Views.SubTabs ||= {}
Searchad.Views.SubTabs.RelRev ||= {}

class Searchad.Views.SubTabs.RelRev.IndexView extends Searchad.Views.Base
  initialize: (options) =>
    _.bindAll(this, 'render', 'initTable')
    @collection = new Searchad.Collections.QueryItemsCollection()
    @shadowCollection = @collection.clone()
    @shadowCollection.bind('reset', @render)
    @collection.bind('reset', @p_missed_items)
    
    super(options)
    @initTable()
    
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @controller.bind('sub-content-cleanup', @unrender)
    @controller.bind('content-cleanup', @unrender)
    @collection.bind('request', =>
      @controller.trigger('search:sub-content:show-spin')
    )
    Utils.InitExportCsv(this, '/search_rel/get_query_items.csv')
    @undelegateEvents()
    @items = []
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
         new_path = "search/#{path.search}/page/#{path.page}/details/sig_comp/query/" + "#{encodeURIComponent(path.query)}/items/#{@items.join(',')}"
         @router.update_path(new_path, trigger: true)


  uncheck_items: (e)=>
    e.preventDefault()
    @$el.find('table td input:checked').attr('checked', false)
    @items = []

  p_missed_items: (e)=>
    view = this
    if e?
      target = $(e.target)
    else
      target = @$el.find('input:checkbox.missed-items')

    @$el.find('table thead th.descending').removeClass('descending')
    @$el.find('table thead th.ascending').removeClass('ascending')

    if target.is(':checked')
      @shadowCollection.reset(@collection.fullCollection.models)
      @render()
    else
      @collection.fullCollection.where(in_top_16: 0).forEach((model) ->
        item_id = model.get('item_id')
        if (index = view.items.indexOf(item_id)) > -1
          view.items.splice(index, 1)
      )
      @shadowCollection.reset(@collection.fullCollection.where(in_top_16: 1))
      @render()
  
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
      formatter: Utils.CustomNumberFormatterNoDecimals
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

    class MyPosition extends Backgrid.NumberCell
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
        if (this.column.get("sortable"))
          if this.direction() == "descending"
            this.sort(columnName, "ascending", (left, right) ->
              leftVal = left.get(columnName)
              rightVal = right.get(columnName)
              if (leftVal == rightVal)
                0
              else if (leftVal > rightVal)
                -1
              else
                1
            )
          else if this.direction() == "ascending"
            @sort(columnName, null)
          else
            @sort(columnName, "descending", (left, right)->
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
    formatter: Utils.CustomNumberFormatterNoDecimals,
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

  render: =>
    return unless @active
    return @render_error(@query) if @shadowCollection.size() == 0
    @controller.trigger('search:sub-content:hide-spin')
  
    item_selection = $('<form class="form-inline item-selection">' +
      'Select upto 4 items &nbsp;' +
      '<i class="icon-hand-down">&nbsp;</i> &nbsp;' +
      '<button class="btn btn-smal do-sig-comp" type="button"> ' +
      'Compare Signals</button> &nbsp;' +
      '<a class="item-uncheck" href="uncheck_items">Uncheck All</a>&nbsp;' +
      '<span class="label sig-comp-msg label-warning">' +
      'Select atleast 1 Item to compare</span>')

    filter = $('<label class="show-rec-items checkbox pull-right">' +
      '<input type="checkbox" class="missed-items"> ' +
      'Show Recommeded Items</label></form>')
    
    if @collection.length == 0
      @$el.append( @grid.render().$el )
    else
      if @$el.find('form.item-selection').length == 0
        if @collection.fullCollection.where(in_top_16: 0).length > 0
          item_selection.append(filter)
        else
          item_selection.append('</form>')
        @$el.append(item_selection)
      
      @grid.render().$el.insertAfter(item_selection)
      @$el.append( @export_csv_button() ) if @$el.find(
        'span.export-csv').length == 0

    @delegateEvents()
    this
  
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @items = []
    @controller.trigger('search:sub-content:hide-spin')
    @undelegateEvents()
