Searchad.Views.SubTabs ||= {}
Searchad.Views.SubTabs.WalmartItems ||= {}

class Searchad.Views.SubTabs.WalmartItems.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @collection =
      new Searchad.Collections.CAWalmartItemsCollection()
    @init_table()
    
    @controller.bind('date-changed', @date_changed )
    @collection.bind('reset', @render_result)
    @collection.bind('request', =>
      @$el.children().not('.ajax-loader').not('.walmart-items-form').remove()
      @controller.trigger('search:sub-content:show-spin')
      $('.walmart-items-form').hide()
      @undelegateEvents()
    )
    @controller.bind('content-cleanup', @unrender)
    @controller.bind('sub-content-cleanup', @unrender)
    @start_date_already_changed = false
    @end_date_already_changed = false
    Utils.InitExportCsv(this, '/comp_analysis/get_walmart_items.csv')
    @undelegateEvents()
    @active = false
    @data = {}

  form_template: JST['backbone/templates/walmart_item/form']

  events: =>
    'click .export-csv a': (e) ->
      query = @data.query.replace(/\s+/g, '_')
      query = query.replace(/"|'/, '')
      if @data.view == "ranged"
        fileName = "walmart_search_results_#{query}_#{@data.start_date}- #{@data.end_date}.csv"
      else
        fileName = "walmart_search_results_#{query}_#{@data.date}.csv"
      @export_csv($(e.target), fileName, @data)

     'click #label-popular-items-over-time ':'popular_items_over_time'
     'click #label-top-32-daily':'top_32_daily'


  render:(data)=>
    @$el.prepend(@form_template())
    walmart = Searchad.UserLatest.SubTab.walmart
    @init_all_date_pickers(walmart.start_date,walmart.end_date )
    @get_items(data)


  render_result: =>
    return unless @active
    # usually the clear is bind with request, since here is using client side pagination,
    # there is not request available to trigger clean up when swiching pages. Clear here. 
    @$el.children().not('.ajax-loader').not('.walmart-items-form').remove()
    @controller.trigger('search:sub-content:hide-spin')
    $('.walmart-items-form').show()
    return @render_error(@query) if @collection.size() == 0
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @export_csv_button() )
    @delegateEvents()
    return this


  render_error: (query) ->
    return unless @active
    @controller.trigger('search:sub-content:hide-spin')
    @$el.html(JST['backbone/templates/shared/no_data']({query:query}))
    # need to delegate events because the "show popular item over time" and "top walmart 32" button needs it
    @delegateEvents()

  
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @controller.trigger('search:sub-content:hide-spin')
    @undelegateEvents()


  top_32_daily:(e)=>
    e.preventDefault()
    # $('#label-popular-items-over-time').removeClass('label-info')
    # $('#label-top-32-daily').addClass('label-info')
    # if top 32, reset date picker
    data = {}
    data.view || = "daily"
    # when click on reset btn, the date pickers needs to reset
    curr_date = @controller.get_filter_params().date
    @init_all_date_pickers(curr_date, curr_date)
    @get_items(data)


  popular_items_over_time:(e)=>
    e.preventDefault()
    # $('#label-popular-items-over-time').addClass('label-info')
    # $('#label-top-32-daily').removeClass('label-info')
    data = {}
    data.view || = "ranged"
    @get_items(data)


  get_items: (data) =>
    @active = true  
    start_date = @$el.find('input.start-date.datepicker').datepicker('getDate')
    end_date = @$el.find('input.end-date.datepicker').datepicker('getDate')
    data.start_date = start_date.toString('M-d-yyyy')
    data.end_date = end_date.toString('M-d-yyyy')

    # when get_items it means user update the select, so save it to user latest selects
    Searchad.UserLatest.SubTab.walmart.start_date = data.start_date
    Searchad.UserLatest.SubTab.walmart.end_date = data.end_date

    data = @process_data(data)
    # if the data param is the exact same stored with collection data. then directly render
    if JSON.stringify(data) == JSON.stringify(@collection.data)
      @render_result()
      return
    @collection.get_items(data)


  process_data:(data)=>
    data || = {}
    if data.query
      @query = data.query
    else
      data.query = @query
    data.view || = "daily"
    @data = data
    return data


  init_table: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection)
    

  init_all_date_pickers:(start_date, end_date)  =>
    # available_end_date = available_end_date || @available_end_date
    start_date_picker = @$el.find('input.start-date.datepicker')
    end_date_picker =  @$el.find('input.end-date.datepicker')
    current_date = @controller.get_filter_params().date
    start_date ||= current_date
    end_date ||= current_date
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
    class ItemCell extends Backgrid.Cell
      item_template:
        JST["backbone/templates/poor_performing/walmart_items/item"]
      
      render: =>
        item =
          image_url: @model.get('image_url')
          item_id: @model.get('item_id')
          title: @model.get('title')
        formatted_value = @item_template(item)
        $(@$el).html(formatted_value)
        return this

    helpInfo = {
      curr_item_price: "We only provide the price available for the most recent available day"
    }

    columns = [{
    name: 'item_id',
    label: I18n.t('dashboard2.item'),
    editable: false,
    cell: ItemCell},
    {name: 'item_revenue',
    label: I18n.t('dashboard2.revenue'),
    editable: false,
    cell: 'number',
    formatter: Utils.CurrencyFormatter},
    {name: 'curr_item_price',
    label: 'Current Item Price',
    editable: false,
    cell: 'number',
    formatter: Utils.CurrencyFormatter,
    headerCell:'helper'
    helpInfo:helpInfo.curr_item_price
    },
    {name: 'shown_count',
    label: I18n.t('dashboard2.shown_count'),
    editable: false,
    # formatter: Utils.CustomNumberFormatter,
    cell: 'integer'},
    {name: 'item_con',
    label: 'Conversion',
    editable: false,
    cell: 'number',
    formatter: Utils.PercentFormatter},
    {name: 'item_atc',
    label: I18n.t('perf_monitor2.add_to_cart_rate'),
    editable: false,
    cell: 'number',
    formatter: Utils.PercentFormatter},
    {name: 'item_pvr',
    label: I18n.t('perf_monitor.product_view_rate'),
    editable: false,
    cell: 'number',
    formatter: Utils.PercentFormatter}]
    
    columns