###
Conversion Rate Dropping QueryView
@author Linghua Jin
@since Dec, 2013
@class Searchad.Views.AdhocQuery.cvrDroppedQueryView
@extend Backbone.View

This is the view for conversion rate dropping. It includes two parts, 1) report 2) search
The searching params are mainly passed from adhoc_query_report index.
If there is query, then do a search, if there is no query, then generate the report

###

Searchad.Views.AdhocQuery||= {}

class Searchad.Views.AdhocQuery.cvrDroppedQueryView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @query_results = $(options.el_results)
    @collection = new Searchad.Collections.CvrDroppedQueryCollection()
    @collection.bind('reset', @render_query_results)
    @collection.bind('request', =>
      @search_results_cleanup()
      @controller.trigger('search:sub-tab-cleanup')
      @query_results.find('.ajax-loader').css('display', 'block')
      @controller.trigger('sub-content-cleanup')
    )
    # instance_variables
    # @available_end_date = new Date(new Date(@controller.get_filter_params()['date']) - 2*7*24*60*60*1000)
    @default_week_apart = 2
    @available_end_date = Max_date
    @data
    # init_csv_export_button
    Utils.InitExportCsv(this, "/search/get_cvr_dropped_query.csv");
    
  events:
    'click .export-csv a': (e) ->
      fileName = "conversion_rate_dropped_query analysis_for #{@data.query_date}_week_apart_#{@data.weeks_apart}.csv"
      @export_csv($(e.target), fileName, @data)

  active: false

  #get_items is usually the first triggered function. It could be trgger from the index or router.  
  get_items: (data) ->
    if data== undefined
      data = @process_query_data(data)
    # reset is bind wiht render_query_results.
    @collection.dataParam = data
    # important, between switch top500 and certain query, must reset current page size to 1
    @collection.state.currentPage = 1;
    @data = data
    @collection.get_items()
    @active = true
    @trigger = true

  process_query_data:(data) =>
    data || = {}
    #set_week_apart
    if data.weeks_apart
      data.weeks_apart= parseInt(data.weeks_apart)
    else
      data.weeks_apart = @default_week_apart;
    #query_date
    if !data.query_date
      current_date= @available_end_date
      query_date = new Date(new Date(current_date) - data.weeks_apart*7*24*60*60*1000);
      data.query_date = query_date.toString('M-d-yyyy')
    #query
    data.query || = ""
    @data = data  # @data is used for csv_export
    return data

  #when collection reset caused by get items, the rendering result is triggered
  render_query_results: =>
    @query_results.find('.ajax-loader').hide()
    if @collection.length == 0
      return @render_error() 

    @initCvrDroppedQueryTable()

    if (@data.query== "")
      result_label = 'Conversion Rate Dropped Query Top 500 Report'
    else 
     result_label = 'Query Comparison for ' + @data.query  

    @query_results.append('<div class="cvr-dropped-query-results-label">'+result_label+'</div>')
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
          tab: 'cvr-dropped-item-comparison')
        new_path = 'adhoc_query/mode/query_comparison'+ '/wks_apart/' + dataParam.weeks_apart + '/query_date/' + dataParam.query_date+"/query/"+ encodeURIComponent(query)
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
    label:'Count Before',
    editable:false
    cell:'number'},
    {name:'query_count_after',
    label:'Count After',
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
    @clean_query_results()
    @active = false


  clean_query_results: =>
     @query_results.children().not('.ajax-loader').remove()

