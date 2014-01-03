Searchad.Views.SubTabs ||= {}
Searchad.Views.SubTabs.WalmartItems ||= {}

class Searchad.Views.SubTabs.WalmartItems.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @collection =
      new Searchad.Collections.CAWalmartItemsCollection()
    @initTable()
    
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
      # data =
      #   date: date
      #   query: @query
      @export_csv($(e.target), fileName, @data)

     'click #label-popular-items-over-time ':'popular_items_over_time'
     'click #label-top-32-daily':'top_32_daily'


  render:(data)=>
    @$el.prepend(@form_template())
    @init_all_date_pickers()
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
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}"))
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
    @init_all_date_pickers()
    @get_items()


  popular_items_over_time:(e)=>
    e.preventDefault()
    # $('#label-popular-items-over-time').addClass('label-info')
    # $('#label-top-32-daily').removeClass('label-info')
    data = {}
    data.start_date = @$el.find('input.start-date.datepicker').datepicker('getDate').toString('M-d-yyyy')
    data.end_date = @$el.find('input.end-date.datepicker').datepicker('getDate').toString('M-d-yyyy')
    data.view || = "ranged"
    @get_items(data)


  get_items: (data) =>
    @active = true
    data = @process_data(data)
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


  initTable: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection)
    

  init_all_date_pickers:  =>
    # available_end_date = available_end_date || @available_end_date
    start_date_picker = @$el.find('input.start-date.datepicker')
    end_date_picker =  @$el.find('input.end-date.datepicker')
    # needs to remove first to make sure date_picker refreshes. reset end date
    @init_one_date_picker(start_date_picker)
    @init_one_date_picker(end_date_picker)


  init_one_date_picker:(el,end_date,selected_date) =>
    current_date = @controller.get_filter_params().date
    selected_date ||= current_date
    end_date ||= Max_date
    el.datepicker("remove");
    el.datepicker({
      endDate: end_date})
    el.datepicker('update', selected_date)


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