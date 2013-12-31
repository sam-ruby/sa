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
    # table has to init here not in render result
    @init_table()
    @collection.bind('reset', @render_query_results)
    @collection.bind('request', =>
      @search_results_cleanup()
      @controller.trigger('search:sub-tab-cleanup')
      @query_results.find('.ajax-loader').css('display', 'block')
      @controller.trigger('sub-content-cleanup')
    )

    Utils.InitExportCsv(this, "/search/get_cvr_dropped_query.csv")
    # instance_variables
    @default_week_apart = 2
    @available_end_date = Max_date
    @data

    
  events:
    'click .export-csv a': (e) ->
      if @data
        fileName = "conversion_rate_dropped_query analysis_for 
          #{@data.query_date}_week_apart_#{@data.weeks_apart}.csv"
        @export_csv($(e.target), fileName, @data)
      

  active: false

  #when collection reset caused by get items, the rendering result is triggered
  render_query_results: =>
    @search_results_cleanup()
    @query_results.find('.ajax-loader').hide()
    if @collection.length == 0
      return @render_error()
    # render the result label
    if (@data.query== "")
      result_label = "Conversion Rate Dropped Query Top 500 Report"
    else
     result_label = 'Query Comparison for '
     if @collection.models[0].get('is_in_top_500')
        in_top_500_label = "In Top 500"

    result_label_template = JST['backbone/templates/adhoc_query/result_label']
    label_data =
      "in_top_500_label": in_top_500_label
      "query" : @data.query
      "result_label": result_label
    @query_results.append(result_label_template(label_data))
    @query_results.append(@grid.render().$el)
    @query_results.append(@paginator.render().$el)
    @query_results.append(@export_csv_button())
    $("li.cvr-dropped-item-comparison").show()
    @$el.find('td a.query').first().click() 

  render_error: ->
    @query_results.append($('<span>').addClass(
      'label label-important').append("No data available"))
    
  unrender: =>
    @search_results_cleanup()
    @active = false
    

  search_results_cleanup: =>
    @query_results.children().not('.ajax-loader').remove()


  #get_items is usually the first triggered function. It could be trgger from the index or router.  
  get_items: (data) ->
    @active = true
    if data== undefined
      data = @process_query_data(data)
    # if the exact same data, don't redo the fetch
    if  @collection.dataParam.query_date == data.query_date and
     @collection.dataParam.weeks_apart == data.weeks_apart and 
     @collection.dataParam.query == data.query and  
     @collection.state.currentPage ==1 
      @render_query_results()
      return
    # reset is bind with render_query_results.
    @collection.dataParam = data
    @data = data
    @collection.getFirstPage()


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


  init_table: ()->
    columns =  @grid_columns()
    @grid = new Backgrid.Grid(
      # className:'cvr-dropped-query-grid'
      columns: columns
      collection: @collection
    )
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )
  

  grid_columns: =>
    that = this
    class SearchQueryCell extends Backgrid.CADQueryCell
      handleQueryClick: (e) =>
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = $(e.target).text()
        dataParam = @model.collection.dataParam
        that.controller.trigger('search:sub-content',
          query: query
          query_date: dataParam.query_date
          weeks_apart: dataParam.weeks_apart
          tab: 'cvr-dropped-item-comparison')
        new_path = 'adhoc_query/mode/query_comparison'+ '/wks_apart/' + dataParam.weeks_apart + '/query_date/' + dataParam.query_date+"/query/"+ encodeURIComponent(query)
        that.router.update_path(new_path)

    helpInfo = Searchad.helpInfo.conversion_rate_dropped_query
    columns = [{name: 'query',
    label: 'Search Word',
    editable: false
    cell: SearchQueryCell
    },
    # rank is determined by query_score
    {name:'query_score',
    label:'Rank Score',
    editable:false,
    cell:'string',
    sortable:true,
    headerCell:'custom'
    helpInfo:helpInfo.query_score
    },
    {name:'query_con_diff',
    label:'Con Diff (%)',
    editable:false
    cell:'number'},
    {name:'query_con_before',
    label:'Con Before (%)',
    editable:false
    cell:'number',
    # className:'conversion-rate'
    },
    {name:'query_con_after',
    label:'Con After (%)',
    editable:false
    cell:'number'},
    {name:'query_revenue_before',
    label:'Rev Before ($)',
    editable:false,
    cell:'number'},
    {name:'query_revenue_after',
    label:'Rev After ($)',
    editable:false,
    cell:'number'},
    {name:'expected_revenue_diff',
    label:'Potential Rev Loss ($)',
    editable:false,
    cell:'number'
    helpInfo: helpInfo.expected_revenue_diff
    headerCell:'custom'
    },
    {name:'query_count_before',
    label:'Count Before',
    editable:false
    cell:'number'},
    {name:'query_count_after',
    label:'Count After',
    editable:false
    cell:'number'},
    ]

    return columns

