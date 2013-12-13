Searchad.Views.CVRDroppedQuery||= {}

class Searchad.Views.CVRDroppedQuery.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    # @query_form = $(options.el_form)
    @query_results = $(options.el_results)
    @collection = new Searchad.Collections.CvrDroppedQueryCollection()
    @collection.bind('reset', @render_query_results)
    @collection.bind('request', =>
      @search_results_cleanup()
      @controller.trigger('search:sub-tab-cleanup')
      @query_results.find('.ajax-loader').css('display', 'block')
      @controller.trigger('sub-content-cleanup')
    )
    # class_variables
    @available_end_date = new Date(new Date(@controller.get_filter_params()['date']) - 2*7*24*60*60*1000)
    @default_week_apart = 2
    @current_date = @controller.get_filter_params()['date']
    @data
    #by default, turn on query_comparison. if it is false, it means on adhoc search mode
    @query_comparison_on = true
    # init_csv_export_button
    Utils.InitExportCsv(this, "/search/get_cvr_dropped_query.csv");
    
  events:
    # 'change input.checkAdvanced':'toggle_search_mode'
    # 'click button.search': 'handle_search'
    # 'click button.reset': 'handle_reset'  
    # 'change .datepicker': 'change_date_picked'  #reset the div alert for selected dates when date range changed
    # 'change select.weeks-apart-select' : 'change_select'
    'click .export-csv a': (e) ->
      fileName = "conversion_rate_dropped_query analysis_for #{@data.query_date}_week_apart_#{@data.weeks_apart}.csv"
      @export_csv($(e.target), fileName, @data)

  # form_template: JST['backbone/templates/cvr_dropped_query/form']

  active: false

  # toggle_search_mode: (e)->
  #   @query_comparison_on = e.currentTarget.checked
  #   @controller.trigger('search:sub-tab-cleanup')
  #   @controller.trigger('sub-content-cleanup')
  #   if @query_comparison_on
  #     @query_form.find('.advanced').show()
  #     $('#search-results').hide()
  #     @query_results.show()
  #     @get_items();
  #   else
  #     @query_form.find('.advanced').hide()
  #     $('#search-results').show()
  #     @query_results.hide()
  # #when changing selected date or week, repaint the alert info displayed. 
  # change_date_picked: ->
  #   weeks_apart= @query_form.find('select').val()
  #   query_date= @query_form.find('input.datepicker').datepicker('getDate')
  #   #reset alert ino for selected dates;
  #   before_start_date = new Date(new Date(query_date) - weeks_apart*7*24*60*60*1000).toString('MMM, d, yyyy'); 
  #   before_end_date = new Date(new Date(query_date) - 24*60*60*1000).toString('MMM, d, yyyy'); 
  #   after_start_date = query_date .toString('MMM, d, yyyy')
  #   after_end_date = new Date(new Date(query_date) - (-(weeks_apart*7-1)*24*60*60*1000)).toString('MMM, d, yyyy'); 
  #   $('.date_range_display').html('Conversion Rate Dropped Query Comparison Report between ['+ before_start_date+' to '+ before_end_date + '] and [' + after_start_date + ' to ' +  after_end_date + ']');

  
  # change_select: ->
  #   weeks_apart= @query_form.find('select').val()
  #   query_date= @query_form.find('input.datepicker').datepicker('getDate')
  #   # set date_picker available dates. since week_range change
  #   @change_date_picked()
  #   available_end_date = new Date(new Date(@current_date) - weeks_apart*7*24*60*60*1000)
  #   @init_date_picker(query_date, available_end_date)

  # handle_search: (e) =>
  #   console.log("search query_comparison_on" , @query_comparison_on);
  #   e.preventDefault()
  #   @clean_query_results()
  #   data =
  #     weeks_apart: @query_form.find('select').val()
  #     query_date:@query_form.find('input.datepicker').datepicker('getDate').toString('M-d-yyyy')
  #     query:@query_form.find('input.query').val()

  #   data = @process_query_data(data);
  #   if @query_comparison_on
  #     console.log("query_comparison_on")
  #     new_path = 'cvr_dropped_query'+ '/wks_apart/' + data.weeks_apart + '/query_date/' + data.query_date+"/query/"+data.query
  #     @router.update_path(new_path)
  #     @get_items(data)
  #   else
  #     console.log("query_comparison_off")
  #     @controller.trigger('search:search',query:data.query)


  # handle_reset: (e) =>
  #   e.preventDefault()
  #   @clean_query_results()
  #   query_date = new Date(new Date(@current_date) - @default_week_apart*7*24*60*60*1000)
  #   @query_form.find('.controls select').val(@default_week_apart+'')
  #   @query_form.find('input.query').val()
  #   console.log(query_date);
  #   @init_date_picker(query_date);
  #   @query_form.find('.cvr-dropped-query-results-label').html
  #   @controller.trigger('sub-content-cleanup')
  #   @controller.trigger('search:sub-tab-cleanup')
  
  # init_date_picker: (default_selected_date, available_end_date) =>
  #   available_end_date = available_end_date || new Date(new Date(@current_date) - @default_week_apart*7*24*60*60*1000)
  #   my_date_picker = @query_form.find('input.datepicker')
  #   # needs to remove first to make sure date_picker refreshes. 
  #   my_date_picker.datepicker("remove");
  #   my_date_picker.datepicker({
  #     endDate: available_end_date})
  #   my_date_picker.datepicker('update', default_selected_date)
    

  # #process data from router
  # process_query_data:(data) =>
  #   data = data || {}
  #   #set_week_apart
  #   if data.weeks_apart
  #     data.weeks_apart= parseInt(data.weeks_apart)
  #   else
  #     data.weeks_apart = 2;
  #   #query_date
  #   if !data.query_date
  #     current_date= @controller.get_filter_params()['date']
  #     query_date = new Date(new Date(current_date) - data.weeks_apart*7*24*60*60*1000);
  #     data.query_date = query_date.toString('M-d-yyyy')
  #   #query


  #   data.query = data.query || ""
  #   # console.log("process_data", data)
  #   # set collection data(query params) for pagination. 
  #   @collection.dataParam = data
  #   @data = data  # @data is used for csv_export
  #   return data
  
  get_items: (data) ->
    # reset is bind wiht render_query_results.
    console.log("get_items", data) 

    @collection.reset();
    @collection.dataParam = data
    
    @data = data
    # if query is undefined, set it to "NULL". Backend controller
    # data.query = data.query || "NULL"
    @collection.get_items(data)
    @active = true
    @trigger = true
 
  # render_form: (data)=>
  #   # $('#data-container').children().not('#cvr-dropped-query').hide();
  #   # @$el.show();
  #   #if there is data, it should come from router
  #   data = @process_query_data(data);
  #   $(@query_form).html(@form_template(data))

  #   end_date = new Date(new Date(@current_date) - data.weeks_apart*7*24*60*60*1000)
  #   @init_date_picker(data.query_date, end_date)
  #   @active = true

  render_query_results: =>
    # console.log("render_query_results", @collection);
    @query_results.find('.ajax-loader').hide()
    if @collection.length == 0
      return @render_error() 
    
    # if (@data.query!= "NULL")
    #   @query_form.find('.cvr-dropped-query-results-label').html('Query Comparison for ' + @data.query )  
    # else 
    #   @query_form.find('.cvr-dropped-query-results-label').html('Conversion Rate Dropped Query Top 500 Report')

    @initCvrDroppedQueryTable()
    result_label
    if (@data.query== "")
      result_label = 'Conversion Rate Dropped Query Top 500 Report'
    else 
     result_label = 'Query Comparison for ' + @data.query  

    @query_results.append('<div class="cvr-dropped-query-results-label">'+result_label+'</div>')
    # ('<div class = "cvr-dropped-query-results-label">'+ result_label +'</div>')
    @query_results.append(@grid.render().$el)
    @query_results.append(@paginator.render().$el)
    @query_results.append(@export_csv_button())
    if @trigger
      @trigger = false
    @$el.find('td a.query').first().trigger('click')
    $("li.cvr-dropped-item-comparison").show();
    this

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

        that.controller.trigger('search:sub-content',
          query: query
          query_date: dataParam.query_date
          weeks_apart: dataParam.weeks_apart
          # view: 'daily'
          tab: 'cvr-dropped-item-comparison')
 
        # new_path = new_path = 'cvr_dropped_query'+ '/wks_apart/' + dataParam.weeks_apart + '/query_date/' + dataParam.query_date+"/query/"+ query
        # that.router.update_path(new_path)
      
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
    {name:'query_con_diff',
    label:'Con Diff',
    editable:false
    cell:'number'},
    {name:'query_con_before',
    label:'Con Before',
    editable:false
    cell:'number',
    # className:'conversion-rate'
    },
    {name:'query_con_after',
    label:'Con After',
    editable:false
    cell:'number'},
    {name:'query_revenue_before',
    label:'Rev Before',
    editable:false,
    cell:'number'},
    {name:'query_revenue_after',
    label:'Rev After',
    editable:false,
    cell:'number'},
    {name:'expected_revenue_diff',
    label:'Rev Diff',
    editable:false,
    cell:'number'
    headerCell:'custom'},
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
      className:'cvr-dropped-query backgrid'
      columns: columns
      collection: @collection
    )

    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )
  
 
  unrender: =>
    # @$el.hide();
    # @query_form.children().remove()
    @clean_query_results()
    @active = false

  clean_query_results: =>
     @query_results.children().not('.ajax-loader').remove()

