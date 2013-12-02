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
    @cvr_dropped_query_form = @$el.find(options.form_selector)
    
  events:
    'click button.search': 'handle_search'
    'click button.reset': 'handle_reset'

  form_template: JST['backbone/templates/query_comparison/cvr_dropped_query_form']

  active: false

  initCvrDroppedQueryTable: ->
    that = this
    console.log(@collection);
    class SearchQueryCell extends Backgrid.Cell
      events:
        'click': 'handleQueryClick'

      handleQueryClick: (e) =>
        e.preventDefault()
        $(e.target).parents('table').find('tr.selected').removeClass(
          'selected')
        $(e.target).parents('tr').addClass('selected')
        query = $(e.target).text()
        that.controller.trigger('search:sub-content',
          query: query
          view: 'daily')
        new_path = 'search/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)
      
      render: =>
        value = @model.get(@column.get('name'))
        formatted_value = '<a class="query" href="#">' + value + '</a>'
        @$el.html(formatted_value)
        @delegateEvents()
        return this

    columns = [{name: 'query',
    label: 'Search Word',
    editable: false
    cell: SearchQueryCell},
    {name:'con_before',
    label:'Conversion Rate Before',
    editable:false
    cell:'number'},
    {name:'con_after',
    label:'Conversion Rate After',
    editable:false
    cell:'number'},
    {name:'diff',
    label:'Conversion Rate Difference',
    editable:false
    cell:'number'},
    {name:'rev_before',
    label:'Revenue Before',
    editable:false
    cell:'number'},
    {name:'rev_after',
    label:'Revenue After',
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


  do_search: (data) =>
    if data
      new_path = 'cvr_dropped_query' +'/sum_count/'+ data.sum_count+ '/wks_apart/' +
        data.weeks_apart + '/query_date/' +
        encodeURIComponent(data.query_date)
      
      @router.update_path(new_path)
      @get_items(data)
  
  handle_search: (e) =>
    e.preventDefault()
    @clean_query_results()
    data =
      weeks_apart: @query_form.find('select').val()
      query_date: @query_form.find('input.datepicker').val()
      sum_count:@query_form.find('input.sum-count').val()

    if data
      @do_search(data)
   
  handle_reset: (e) =>
    e.preventDefault()
    @clean_query_results()
    query_date = @controller.get_filter_params()['date']
    query_date = new Date(new Date(query_date) - 7*24*60*60*1000)
    @query_form.find('input.sum-count').val('5000')
    @query_form.find('.controls select').val('2')
    @query_form.find('input.datepicker').datepicker(
      'update', query_date.toString('M-d-yyyy'))
  
  get_items: (data) ->
    query_date = @controller.get_filter_params()['date']
    query_date = new Date(new Date(query_date) - 7*24*60*60*1000)
    if data 
      # data.query = decodeURIComponent(data.query)
      query_date = new Date(decodeURIComponent(data.query_date))
      data.weeks_apart = parseInt(data.weeks_apart)
      data.sum_count = parseInt(data.sum_count)
    else
      data =
        weeks_apart: 2
        sum_count:5000

    if data 
      image =$('<img>').addClass('ajax-loader').attr(
        'src', '/assets/ajax_loader.gif').css('display', 'block')
      @collection.get_items(data)
    @active = true
 
  render_form:=>
    query_date = @controller.get_filter_params()['date']
    query_date = new Date(new Date(query_date) - 7*24*60*60*1000)
    data =
      query_date:query_date
      weeks_apart: 2
      sum_count:5000
    $(@query_form).html(@form_template(data))
    $(@query_form).find('input.datepicker').datepicker()    
    @query_form.find('input.datepicker').datepicker(
      'update', query_date.toString('M-d-yyyy'))
    @active = true

  render_query_results: =>
    @query_results.find('.ajax-loader').hide()
    return @render_error() if @collection.length == 0
    
    @query_results.append($('<div>').css('text-align', 'left').css(
      'margin-bottom': '1em').append(
      $('<i>').addClass('icon-search').css(
        'font-size', 'large').append(
        '&nbsp; Results for : ' + 'Conversion Rate Dropped Query')))
    @initCvrDroppedQueryTable()
    @query_results.append(@grid.render().$el)
    @query_results.append(@paginator.render().$el)
    @query_results.append(@export_csv_button())

  # process_data: (data) ->
  #   [{data: [
  #     {name: 'Product View Rate'
  #     y: data.query_pvr
  #     dataLabels:
  #       format: '<b>PVR</b> ({point.y:,.2f}%)'
  #     },
  #     {name: 'Add to Cart Rate'
  #     y: data.query_atc
  #     },
  #     {name: 'Conversion Rate'
  #     y: data.query_con
  #     }]}]

  search_results_cleanup: =>
    @query_results.children().not('.ajax-loader').remove()

  render_error: ->
    @controller.trigger('search:sub-tab-cleanup')
    @query_results.append($('<span>').addClass(
      'label label-important').append("No data available"))
  
  render_table: (data, dom) =>
    grid = @initCvrDroppedQueryTable(data)
    dom.append(grid.render().$el)
 
  unrender: =>
    @query_form.children().remove()
    @clean_query_results()
    @active = false

  clean_query_results: =>
     @query_results.children().not('.ajax-loader').remove()

