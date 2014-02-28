Searchad.Views.UpTrending ||= {}

class Searchad.Views.UpTrending.IndexView extends Searchad.Views.Trending
  initialize: (options) =>
    @collection = new Searchad.Collections.UpTrendingCollection()
    @content_area = @$el.find(options.content_selector).first()
    Utils.InitExportCsv(
      this, "/trending/get_search_words.csv")
    @gridCols = [{
      name: 'query',
      label: I18n.t('query'),
      editable: false,
      cell: @queryCell()},
      {name: 'query_count',
      label: 'Count',
      editable: false,
      cell: 'integer'},
      {name: 'revenue',
      label: I18n.t('search_analytics.revenue'),
      editable: false,
      cell: 'number',
      formatter: Utils.CurrencyFormatter}]
    
    super(options)
    @listenTo(@controller, 'up-trending:index',=>
      @$el.find('ul.trending').children('li').removeClass('active')
      @$el.find('ul.trending a.up').parents('li').addClass('active')
    )

  events: =>
    'click ' + @options.content_selector + ' .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      fileName = "up_trending_#{date}.csv"
      data =
        view: 'daily'
        date: date
      @export_csv($(e.target), fileName, data)
    
    'click a.up': (e) ->
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
          show_only_series: ['query_count']
          enable_range:
            max_date: current_date.toString('yyyy-MM-dd')
            min_date: current_date.add(-5).days().toString('yyyy-MM-dd')
        )
        new_path = 'trending/up/query/' + encodeURIComponent(query)
        that.router.update_path(new_path)
      false
    QueryCell
