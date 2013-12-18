Searchad.Views.SubTabs ||= {}
Searchad.Views.SubTabs.WalmartItems ||= {}

class Searchad.Views.SubTabs.WalmartItems.IndexView extends Backbone.View
  initialize: (options) =>
    @controller = SearchQualityApp.Controller
    @collection =
      new Searchad.Collections.CAWalmartItemsCollection()
    @initTable()
    
    @controller.bind('date-changed', =>
      @get_items() if @active)
    @collection.bind('reset', @render_result)
    
    @collection.bind('request', =>
      @$el.children().not('.ajax-loader').not('.cvr-dropped-query-form').remove()
      @controller.trigger('search:sub-content:show-spin')
      @undelegateEvents()
    )

    @controller.bind('content-cleanup', @unrender)
    @controller.bind('sub-content-cleanup', @unrender)
    Utils.InitExportCsv(this, '/comp_analysis/get_walmart_items.csv')
    @undelegateEvents()
    @active = false
    @current_date = @controller.get_filter_params().date
    @data = {}

  form_template: JST['backbone/templates/walmart_item/form']

  events: =>
    'click .export-csv a': (e) ->
      # date = @controller.get_filter_params().date
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
    {name: 'shown_count',
    label: I18n.t('dashboard2.shown_count'),
    editable: false,
    formatter: Utils.CustomNumberFormatter,
    cell: 'integer'},
    {name: 'item_con',
    label: I18n.t('perf_monitor2.conversion_rate'),
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

  initTable: =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection)
    
  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @controller.trigger('search:sub-content:hide-spin')
    @undelegateEvents()

  init_all_date_pickers:  =>
    # available_end_date = available_end_date || @available_end_date
    start_date_picker = @$el.find('input.start-date.datepicker')
    end_date_picker =  @$el.find('input.end-date.datepicker')
    # needs to remove first to make sure date_picker refreshes. reset end date
    @init_one_date_picker(start_date_picker)
    @init_one_date_picker(end_date_picker)

  init_one_date_picker:(el,end_date,selected_date) =>
    selected_date ||= @current_date
    end_date ||=@current_date
    el.datepicker("remove");
    el.datepicker({
      endDate: end_date})
    el.datepicker('update', selected_date)


  render:(data)=>
    @$el.append(@form_template())
    @init_all_date_pickers()
    @get_items(data)


  process_data:(data)=>
    data || = {}
    if data.query
      @query = data.query
    else
      data.query = @query
    data.view || = "daily"
    @data = data;

  get_items: (data) =>
    @active = true
    @process_data(data);
    @collection.get_items(data)

  top_32_daily:(e)=>
    e.preventDefault()
    # if top 32, reset date picker
    @init_all_date_pickers()
    @get_items()

  popular_items_over_time:(e)=>
    e.preventDefault()
    data = {}
    data.start_date = @$el.find('input.start-date.datepicker').datepicker('getDate').toString('M-d-yyyy')
    data.end_date = @$el.find('input.end-date.datepicker').datepicker('getDate').toString('M-d-yyyy')
    data.view || = "ranged"
    @get_items(data)

  render_error: (query) ->
    return unless @active
    @controller.trigger('search:sub-content:hide-spin')
    @$el.append( $('<span>').addClass('label label-important').append(
      "No data available for #{query}") )
  
  render_result: =>
    return unless @active
    @controller.trigger('search:sub-content:hide-spin')
    return @render_error(@query) if @collection.size() == 0

    
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @export_csv_button() )
    @delegateEvents()
    return this
