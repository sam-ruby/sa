Searchad.Views.PoorPerforming ||= {}

class Searchad.Views.PoorPerforming.IndexView extends Searchad.Views.Trending
  initialize: (options) =>
    @collection = new Searchad.Collections.PoorPerformingCollection()
    Utils.InitExportCsv(
      this, "/poor_performing/get_search_words.csv")
    @gridCols = [{
      name: 'query',
      label: I18n.t('query'),
      editable: false,
      cell: @queryCell()},
      {name: 'rank',
      label: 'Rank',
      editable: false,
      cell: 'number'
      formatter: Utils.CustomNumberFormatter},
      {name: 'revenue',
      label: 'Total Revenue',
      editable: false,
      cell: 'number',
      formatter: Utils.CurrencyFormatter},
      {name: 'query_count',
      label: 'Total Count',
      editable: false,
      cell: 'integer'}]
    
    super(options)
    @listenTo(@router, 'route', (route, params) =>
      @$el.children().not('.ajax-loader').remove() if @active
      if route == 'search' and @router.task == 'performance' and @router.sub_task == 'poor_performing'
        @$el.children().not('.ajax-loader').remove()
        @get_items()
      else
        @active = false
    )
     
  events: =>
    csv_event = "click .export-csv"
    events = {}

    events[csv_event] = (e)->
      date = @controller.get_filter_params().date
      fileName = "poor_performing_#{date}.csv"
      data =
        view: 'daily'
        date: date
      @export_csv($(e.target), fileName, data)
    events['click a.pp'] = (e) ->
      $(e.target).parents('ul').children('li').removeClass('active')
      $(e.target).parents('li').addClass('active')
      @controller.trigger('trending:cleanup')
      @get_items()
      false
    
    events
  
  unrender: =>
    @clean_content()
    @$el.find('.ajax-loader').hide()
    super()

  prepare_for_render: =>
    super()
    @$el.find('.ajax-loader').css('display', 'block')
   
  render: =>
    super()
    
  queryCell:  ->
    that = this
    class QueryCell extends Backgrid.CADQueryCell
      handleQueryClick: (e) ->
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = $(e.target).text()
        current_date = new Date(@controller.get_filter_params().date)
        that.controller.trigger('search:sub-content',
          query: query
          view: 'daily'
          show_only_series: ['query_count', 'query_con']
          enable_range:
            max_date: current_date.toString('yyyy-MM-dd')
            min_date: current_date.add(-30).days().toString('yyyy-MM-dd')
        )
        new_path = 'search/performance/poor_performing/query/' +
          encodeURIComponent(query)
        that.router.update_path(new_path)
      false
