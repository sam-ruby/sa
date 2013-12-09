Searchad.Views.CVRDroppedQuery||= {}

class Searchad.Views.CVRDroppedQuery.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @query_form = $(options.el_form)
    @query_results = $(options.el_results)
    @collection = new Searchad.Collections.CvrDroppedQueryCollection()
    @collection.bind('reset', @render_query_results)
    @collection.bind('request', =>
      @search_results_cleanup()
      @query_results.find('.ajax-loader').css('display', 'block')
      @controller.trigger('sub-content-cleanup')
    )
    @available_end_date = new Date(new Date(@controller.get_filter_params()['date']) - 2*7*24*60*60*1000)
    @default_week_apart = 2
    @current_date = @controller.get_filter_params()['date']
    
  events:
    'click button.search': 'handle_search'
    'click button.reset': 'handle_reset'  
    'change .datepicker': 'change_date_picked'  #reset the div alert for selected dates when date range changed
    'change select.weeks-apart-select' : 'change_select'

  form_template: JST['backbone/templates/cvr_dropped_query/form']

  active: false

  #when changing selected date or week, repaint the alert info displayed. 
  change_date_picked: ->
    weeks_apart= @query_form.find('select').val()
    query_date= @query_form.find('input.datepicker').datepicker('getDate')
    #reset alert ino for selected dates;
    before_start_date = new Date(new Date(query_date) - weeks_apart*7*24*60*60*1000).toString('MMM, d, yyyy'); 
    before_end_date = new Date(new Date(query_date) - 24*60*60*1000).toString('MMM, d, yyyy'); 
    after_start_date = query_date .toString('MMM, d, yyyy')
    after_end_date = new Date(new Date(query_date) - (-(weeks_apart*7-1)*24*60*60*1000)).toString('MMM, d, yyyy'); 
    $('.date_range_display').html('Investigage Conversion Rate Dropped Query between ['+ before_start_date+' to '+ before_end_date + '] and [' + after_start_date + ' to ' +  after_end_date + ']');

  
  change_select: ->
    weeks_apart= @query_form.find('select').val()
    query_date= @query_form.find('input.datepicker').datepicker('getDate')
    # set date_picker available dates. since week_range change
    @change_date_picked()
    available_end_date = new Date(new Date(@current_date) - weeks_apart*7*24*60*60*1000)
    @init_date_picker(query_date, available_end_date)

  handle_search: (e) =>
    e.preventDefault()
    @clean_query_results()
    data =
      weeks_apart: @query_form.find('select').val()
      query_date:@query_form.find('input.datepicker').datepicker('getDate').toString('M-d-yyyy')

    data = @process_query_data(data);
    new_path = 'cvr_dropped_query'+ '/wks_apart/' + data.weeks_apart + '/query_date/' + data.query_date
    @router.update_path(new_path)
    @get_items(data)


  handle_reset: (e) =>
    e.preventDefault()
    @clean_query_results()
    query_date = new Date(new Date(@current_date) - @default_week_apart*7*24*60*60*1000)
    @query_form.find('.controls select').val(@default_week_apart+'')
    console.log(query_date);
    @init_date_picker(query_date);
    @controller.trigger('sub-content-cleanup')
  
  init_date_picker: (default_selected_date, available_end_date) =>
    available_end_date = available_end_date || new Date(new Date(@current_date) - @default_week_apart*7*24*60*60*1000)
    my_date_picker = @query_form.find('input.datepicker')
    # needs to remove first to make sure date_picker refreshes. 
    my_date_picker.datepicker("remove");
    my_date_picker.datepicker({
      endDate: available_end_date})
    my_date_picker.datepicker('update', default_selected_date)
    

  #process data from router
  process_query_data:(data) =>
    data = data || {}
    #set_week_apart
    if data.weeks_apart
      data.weeks_apart= parseInt(data.weeks_apart)
    else
      data.weeks_apart = 2;
    #query_date
    if !data.query_date
      current_date= @controller.get_filter_params()['date']
      query_date = new Date(new Date(current_date) - data.weeks_apart*7*24*60*60*1000);
      data.query_date = query_date.toString('M-d-yyyy')

    # set collection data(query params) for pagination. 
    @collection.dataParam = data
    return data
  
  get_items: (data) ->
    # reset is bind wiht render_query_results. 
    @collection.reset();
    @collection.get_items(data)
    @active = true
 
  render_form: (data)=>
    # $('#data-container').children().not('#cvr-dropped-query').hide();
    @$el.show();
    #if there is data, it should come from router
    data = @process_query_data(data);
    $(@query_form).html(@form_template(data))
    end_date = new Date(new Date(@current_date) - data.weeks_apart*7*24*60*60*1000)
    @init_date_picker(data.query_date, end_date)
    @active = true

  render_query_results: =>
    @query_results.find('.ajax-loader').hide()
    if @collection.length == 0
      return @render_error() 
    
    @query_results.append($('<div>').css('text-align', 'left').css(
      'margin-bottom': '1em').append(
      $('<i>').addClass('icon-search').css(
        'font-size', 'large').append(
        '&nbsp; Results for : ' + 'Conversion Rate Dropped Query')))
    @initCvrDroppedQueryTable()
    @query_results.append(@grid.render().$el)
    @query_results.append(@paginator.render().$el)
    # TODO need to add export_csv_button
    @query_results.append(@export_csv_button())

  search_results_cleanup: =>
    @query_results.children().not('.ajax-loader').remove()

  render_error: ->
    # @controller.trigger('search:sub-tab-cleanup')
    @query_results.append($('<span>').addClass(
      'label label-important').append("No data available"))

  initCvrDroppedQueryTable: ->
    that = this
    class SearchQueryCell extends Backgrid.Cell
      events:
        'click': 'handleQueryClick'
      handleQueryClick: (e) =>
        e.preventDefault()
        $(e.target).parents('table').find('tr.selected').removeClass(
          'selected')
        $(e.target).parents('tr').addClass('selected')
        query = $(e.target).text()
        dataParam = @model.collection.dataParam
        that.controller.trigger('cvr_dropped_query:item_comparison',
          query: query
          query_date: dataParam.query_date
          weeks_apart: dataParam.weeks_apart
        )
      
      render: =>
        value = @model.get(@column.get('name'))
        formatted_value = '<a class="query" href="#">' + value + '</a>'
        @$el.html(formatted_value)
        @delegateEvents()
        return this

    columns = [{name: 'query',
    label: 'Search Word',
    editable: false
    cell: SearchQueryCell
    },
    {name:'query_con_before',
    label:'Conversion Before',
    editable:false
    cell:'number',
    # className:'conversion-rate'
    },
    {name:'query_con_after',
    label:'Conversion After',
    editable:false
    cell:'number'},
    {name:'query_con_diff',
    label:'Conversion Diff',
    editable:false
    cell:'number'},
    {name:'query_revenue_before',
    label:'Revenue Before',
    editable:false,
    # formatter: Utils.CurrencyFormatter
    cell:'number'},
    {name:'query_revenue_after',
    label:'Revenue After',
    editable:false,
    # formatter: Utils.CurrencyFormatter,
    cell:'number'},
    {name:'query_count_before',
    label:'Query Count Before',
    editable:false
    cell:'number'},
    {name:'query_count_after',
    label:'Query Count After',
    editable:false
    cell:'number'},
    {name:'query_score',
    label:'Rank Metric',
    editable:false
    cell:'number'},
    ]

    @grid = new Backgrid.Grid(
      columns: columns
      collection: @collection
    )

    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )
  
 
  unrender: =>
    @$el.hide();
    @query_form.children().remove()
    @clean_query_results()
    @active = false

  clean_query_results: =>
     @query_results.children().not('.ajax-loader').remove()

