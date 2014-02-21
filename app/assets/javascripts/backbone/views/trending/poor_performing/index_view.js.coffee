Searchad.Views.PoorPerforming ||= {}

class Searchad.Views.PoorPerforming.IndexView extends Searchad.Views.Trending
  initialize: (options) =>
    @collection = new Searchad.Collections.PoorPerformingCollection()
    @content_area = @$el.find(options.content_selector).first()
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
      formatter: Utils.CustomNumberFormatter}]
    
    super(options)
    @listenTo(@controller, 'trending:index',=>
      @$el.find('ul.trending').children('li').removeClass('active')
      @$el.find('ul.trending a.pp').parents('li').addClass('active')
    )
     
  events: =>
    'click ' + @options.content_selector + ' .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      fileName = "poor_performing_#{date}.csv"
      data =
        view: 'daily'
        date: date
      @export_csv($(e.target), fileName, data)
    
    'click a.pp': (e) ->
      $(e.target).parents('ul').children('li').removeClass('active')
      $(e.target).parents('li').addClass('active')
      @controller.trigger('trending:cleanup')
      @get_items()
      false
  
  unrender: =>
    @clean_content()
    @content_area.find('.ajax-loader').hide()
    super()

  prepare_for_render: =>
    super()
    @content_area.find('.ajax-loader').css('display', 'block')
   
  render: =>
    super(@content_area)
    
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
        new_path = 'trending/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)
      false
