#= require backbone/views/base

Searchad.Views.SubTabs ||= {}
Searchad.Views.SubTabs.WalmartItems ||= {}

class Searchad.Views.SubTabs.WalmartItems.IndexView extends Searchad.Views.Base
  initialize: (options) =>
    @collection =
      new Searchad.Collections.CAWalmartItemsCollection()
    super(options)
    
    @controller.bind('date-changed', @date_changed )
    @collection.bind('reset', @render_result)
    @collection.bind('request', =>
      @controller.trigger('search:sub-content:show-spin')
      @undelegateEvents()
    )
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('sub-content-cleanup', @unrender)
    @start_date_already_changed = false
    @end_date_already_changed = false
    Utils.InitExportCsv(this)
    @div_container = $('<div>')
    @div_container.hide()
    @$el.append( @div_container )
    
    @init_table()
    @undelegateEvents()
    @active = false
    @data = {}
    @data.view = 'daily'
    @items = []

  form_template: JST['backbone/templates/walmart_item/form']

  events: =>
    'click .export-csv a': (e) ->
      query = @data.query.replace(/\s+/g, '_')
      query = query.replace(/"|'/, '')
      if @data.view == "ranged"
        fileName = "walmart_search_results_#{query}_#{@data.start_date}- #{@data.end_date}.csv"
      else
        fileName = "walmart_search_results_#{query}_#{@data.date}.csv"
      @export_csv($(e.target), @data)
    'click a.item-uncheck': 'uncheck_items'
    'click #label-popular-items-over-time ':'popular_items_over_time'
    'click #label-top-32-daily':'top_32_daily'
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

  uncheck_items: (e)=>
    e.preventDefault()
    @$el.find('table td input:checked').attr('checked', false)
    @$el.find('table td input:disabled').removeAttr('disabled')
    @items = []
  
  render: (data)=>
    for k, v of data when k != 'view'
      @data[k] = v
    @items = []
    @div_container.show()
    @grid.render()
    if @div_container.parents().length == 0
      @$el.append(@div_container)
    @get_items()

  render_result: =>
    return unless @active
    @controller.trigger('search:sub-content:hide-spin')
    @delegateEvents()
    return this

  unrender: =>
    @active = false
    #@data.view = 'daily'
    #@div_container.find('table th.rank').css('display', 'table-cell')
    @div_container.hide()
    @controller.trigger('search:sub-content:hide-spin')
    @undelegateEvents()

  top_32_daily:(e)=>
    e.preventDefault()
    # $('#label-popular-items-over-time').removeClass('label-info')
    # $('#label-top-32-daily').addClass('label-info')
    # if top 32, reset date picker
    @data.view = "daily"

    # when click on reset btn, the date pickers needs to reset
    curr_date = @controller.get_filter_params().date
    @init_all_date_pickers(curr_date, curr_date)
    @div_container.find('table th.rank').css('display', 'table-cell')
    @div_container.find('div.walmart-results-label span').text(
      'Top 16 Relevance Items')
    @grid.sort('rank', 'ascending')
    @get_items()

  popular_items_over_time:(e)=>
    e.preventDefault()
    # $('#label-popular-items-over-time').addClass('label-info')
    # $('#label-top-32-daily').removeClass('label-info')
    @data.view = "ranged"
    @div_container.find('table th.rank').css('display', 'none')
    @div_container.find('div.walmart-results-label span').text(
      'Top 16 Items by Impressions Over Time')
    @grid.sort('shown_count', 'descending')
    @get_items()

  get_items: () =>
    @active = true
    start_date = @$el.find('input.start-date.datepicker').datepicker('getDate')
    end_date = @$el.find('input.end-date.datepicker').datepicker('getDate')
    @data.start_date = start_date.toString('yyyy-M-d')
    @data.end_date = end_date.toString('yyyy-M-d')

    # when get_items it means user update the select, so save it 
    # to user latest selects
    #Searchad.UserLatest.SubTab.walmart.start_date = @data.start_date
    #Searchad.UserLatest.SubTab.walmart.end_date = @data.end_date
    
    @process_data()
    if JSON.stringify(@data) == JSON.stringify(@collection.data)
      return @render_result()
    @collection.get_items(@data)

  process_data:()=>
    if @data.query?
      @query = @data.query
    else
      @data.query = @query

  init_table: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
      emptyText: 'No Data'
      className: 'walmart-results'
    )
    @grid.sort('rank', 'ascending')
    @div_container.append( @form_template() )
    #walmart = Searchad.UserLatest.SubTab.walmart
    @init_all_date_pickers()
    @div_container.append( @grid.render().$el )
    @div_container.append( @export_csv_button() )

  init_all_date_pickers: =>
    # available_end_date = available_end_date || @available_end_date
    start_date_picker = @div_container.find('input.start-date.datepicker')
    end_date_picker =  @div_container.find('input.end-date.datepicker')
    current_date = @controller.get_filter_params().date
    start_date = current_date
    end_date = current_date
    checkin = start_date_picker.datepicker(
      endDate: Max_date
      onRender:  ->
        setDate(start_date)
    ).on("changeDate", (ev) ->
      newDate = new Date(ev.date)
      checkout.setValue(newDate)
      checkout.setStartDate(newDate)
      checkin.hide()
      $(end_date_picker)[0].focus()
    ).data("datepicker")


    checkout = end_date_picker.datepicker(
      endDate: Max_date
      # selected_date: start_date
      onRender: (date) ->
        setDate(end_date)
    ).on("changeDate", (ev) ->
      newDate = new Date(ev.date)
      checkout.setEndDate(newDate)
      checkout.hide()
    ).data("datepicker")

    start_date_picker.datepicker('update', start_date)
    end_date_picker.datepicker('update', end_date)


  # this date is the date_picker
  date_changed:=>
    if @active
      @init_all_date_pickers()
      @get_items()


  gridColumns: =>
    view = this
    class ItemCell extends Backgrid.Cell
      item_template:
        JST["backbone/templates/poor_performing/walmart_items/item"]
      
      events: =>
        'click input:checkbox': (e) =>
          if $(e.target).is(':checked')
            view.items.push(@model.get('item_id'))
            if view.items.length == 4
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
        item =
          image_url: @model.get('image_url')
          item_id: @model.get('item_id')
          title: @model.get('title')
        formatted_value = @item_template(item)
        input_box = '<label class="checkbox signal-comp"><input type="checkbox"/></label>'
        @$el.append(input_box, formatted_value)
        @delegateEvents()
        return this
     
    class SignalComparisonHeaderCell extends Backgrid.HeaderCell
      render: =>
        @$el.html('<button class="btn do-signal-comp" type="button">Compare Signals</button>')
        @delegateEvents()
        return this

    class SignalComparisonCell extends Backgrid.Cell
      events: =>
        'click input:checkbox': (e) =>
          if $(e.target).is(':checked')
            view.items.push(@model.get('item_id'))
            if view.items.length == 4
              view.$el.find('table input:checkbox').not(':checked').attr('disabled', true)
          
          else
            item_id = @model.get('item_id')
            if (index = view.items.indexOf(item_id)) > -1
              view.items.splice(index, 1)
              
              if view.items.length < 4
                view.$el.find('table input:disabled').removeAttr('disabled')
      
      render: =>
        @$el.html('<label class="checkbox signal-comp"><input type="checkbox"/></label>')
        @delegateEvents()
        return this
    
    check_render = ->
      if view.data? and view.data.view == 'ranged'
        false
      else
        true

    columns = [{name: 'rank',
    label: 'Rank',
    editable: false,
    sortable: true,
    cell: 'integer',
    renderable: check_render,
    headerCell: @NumericHeaderCell},
    {name: 'item_id',
    label: I18n.t('dashboard2.item'),
    editable: false,
    cell: ItemCell},
    {name: 'curr_item_price',
    label: 'Latest Item Price',
    editable: false,
    sortable: true,
    cell: 'number',
    headerCell: @NumericHeaderCell,
    formatter: Utils.CurrencyFormatter},
    {name: 'shown_count',
    label: 'Impressions',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: 'integer',
    formatter: Utils.CustomNumberFormatterNoDecimals},
    {name: 'i_con',
    label: 'Conversion',
    editable: false,
    cell: 'number',
    headerCell: @NumericHeaderCell,
    formatter: Utils.PercentFormatter},
    {name: 'i_atc',
    label: 'Add to Cart',
    editable: false,
    cell: 'number',
    headerCell: @NumericHeaderCell,
    formatter: Utils.PercentFormatter},
    {name: 'i_pvr',
    label: 'Product View',
    editable: false,
    cell: 'number',
    headerCell: @NumericHeaderCell,
    formatter: Utils.PercentFormatter},
    {name: 'i_oos',
    label: 'Out Of Stock',
    editable: false,
    headerCell: @NumericHeaderCell,
    cell: @OosCell}]
    
    columns
