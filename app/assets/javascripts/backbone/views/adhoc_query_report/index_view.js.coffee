Searchad.Views.AdhocQuery||= {}

class Searchad.Views.AdhocQuery.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @query_form = $(options.el_form)
    @available_end_date = new Date(new Date(@controller.get_filter_params()['date']) - 2*7*24*60*60*1000)
    @default_week_apart = 2
    @current_date = @controller.get_filter_params()['date']
    @data
    #by default, turn on query_comparison. if it is false, it means on adhoc search mode
    @query_comparison_on = true
    
  events:
    'change input.checkAdvanced':'click_toggle_search_mode'
    'click button.search': 'handle_search'
    # 'click button.reset': 'handle_reset'  
    'change .datepicker': 'change_date_picked'  #reset the div alert for selected dates when date range changed
    'change select.weeks-apart-select' : 'change_select'
    "click i.query_search_clear_icon": "click_search_clear_icon"
    "input.query":"toggleRemoveIcon"

  form_template: JST['backbone/templates/adhoc_query/form']

  active: false

  click_toggle_search_mode: (e)->
    @query_comparison_on = e.currentTarget.checked
    @toggle_search_mode(@query_comparison_on)
    # @reset_form()

  toggle_search_mode: (query_comparison_on)->

    @controller.trigger('search:sub-tab-cleanup')
    @controller.trigger('sub-content-cleanup')
    if query_comparison_on
      @query_form.find('.advanced').show()
      $('#search-results').hide()
      $('#cvr-dropped-query-results').show()
      # @query_form.find('input.checkAdvanced').attr( 'checked', query_comparison_on )
      # @reset_form();
    else
      @query_form.find('.advanced').hide()
      $('#search-results').show()
      $('#cvr-dropped-query-results').hide()
     # set checkbox to be query_comparison_on
      # @query_form.find('input.checkAdvanced').attr( 'checked', query_comparison_on )
      # @reset_form();

  #when changing selected date or week, repaint the alert info displayed. 
  change_date_picked: ->
    weeks_apart= @query_form.find('select').val()
    query_date= @query_form.find('input.datepicker').datepicker('getDate')
    #reset alert ino for selected dates;
    before_start_date = new Date(new Date(query_date) - weeks_apart*7*24*60*60*1000).toString('MMM, d, yyyy'); 
    before_end_date = new Date(new Date(query_date) - 24*60*60*1000).toString('MMM, d, yyyy'); 
    after_start_date = query_date .toString('MMM, d, yyyy')
    after_end_date = new Date(new Date(query_date) - (-(weeks_apart*7-1)*24*60*60*1000)).toString('MMM, d, yyyy'); 
    $('.date_range_display').html('<p class= "selected_date_range_text">Selected <span>'+ before_start_date+' to '+ before_end_date + ' as before</span> and <span>' + after_start_date + ' to ' +  after_end_date + '</span> as after</p>');

  
  change_select: ->
    weeks_apart= @query_form.find('select').val()
    query_date= @query_form.find('input.datepicker').datepicker('getDate')
    # set date_picker available dates. since week_range change
    @change_date_picked()
    available_end_date = new Date(new Date(@current_date) - weeks_apart*7*24*60*60*1000)
    @init_date_picker(query_date, available_end_date)

  handle_search: (e) =>
    e.preventDefault()
    @search()

    # @clean_query_results()

  search: =>
    data =
      weeks_apart: @query_form.find('select').val()
      query_date:@query_form.find('input.datepicker').datepicker('getDate').toString('M-d-yyyy')
      query:@query_form.find('input.query').val()

    data = @process_query_data(data);
    new_path
    console.log(@query_comparison_on)
    if @query_comparison_on
       @controller.trigger('adhoc:cvr_dropped_query', data)
       new_path = 'adhoc_query/mode/query_comparison'+ '/wks_apart/' + @data.weeks_apart + '/query_date/' + @data.query_date+'/query/'+ @data.query
    else
      @controller.trigger('adhoc:search',query:data.query)
      new_path = 'adhoc_query/mode/search'+'/query/'+ @data.query
     
    @router.update_path(new_path)


  reset_form:  =>
    # e.preventDefault()
    query_date = new Date(new Date(@current_date) - @default_week_apart*7*24*60*60*1000)
    @query_form.find('.controls select').val(@default_week_apart+'')
    # @query_form.find('input.query').val('')
    @clearSearchBox()
    @init_date_picker(query_date)
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
    #query
    if data.query
      data.query = decodeURI(data.query)
    else
      data.query = ""
    @data = data  # @data is used for csv_export
    return data
 
 
  render_form: (data)=>
    console.log("render_form", data)
    #if there is data, it should come from router
    # @query_comparison_on = data.query_comparison_on
    data = @process_query_data(data);
    console.log("data_after_process", data);
    $(@query_form).html(@form_template(data))
    # @toggleRemoveIcon()
    if data.query.length > 0
      @query_form.find(".query_search_clear_icon").show()

    end_date = new Date(new Date(@current_date) - data.weeks_apart*7*24*60*60*1000)
    console.log(data.query_date);
    @init_date_picker(data.query_date, end_date)
    @active = true


  search_results_cleanup: =>
    @query_results.children().not('.ajax-loader').remove()

  render_error: ->
    # @controller.trigger('search:sub-tab-cleanup')
    @query_results.append($('<span>').addClass(
      'label label-important').append("No data available"))
 
  unrender: =>
    @query_form.children().remove()
    @active = false

  clearSearchBox: => 
    #clear search box
    @query_form.find("input.query").val("")
    @query_form.find(".query_search_clear_icon").hide()
    # @search()
  click_search_clear_icon: =>
    @clearSearchBox()
    @search()

  toggleRemoveIcon: =>
    query = @query_form.find("input.query").val()
    if query.length > 0
      @query_form.find(".query_search_clear_icon").show()
    else     
      #if user press delete button and the box is empty
      @clearSearchBox()


