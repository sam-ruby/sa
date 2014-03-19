Searchad.Views.UpTrending ||= {}

class Searchad.Views.UpTrending.IndexView extends Searchad.Views.Trending
  initialize: (options) =>
    @collection = new Searchad.Collections.UpTrendingCollection()
    @content_area = @$el.find(options.content_selector).first()
    Utils.InitExportCsv(
      this, "/poor_performing/get_trending_words.csv")
    @gridCols = [{
      name: 'query',
      label: I18n.t('query'),
      editable: false,
      cell: @queryCell()},
      {name: 'query_count',
      label: 'Total Count',
      editable: false,
      cell: 'integer'},
      {name: 'query_count_diff',
      label: 'Traffic Delta',
      editable: false,
      cell: 'integer'},

      {name: 'revenue',
      label: 'Total Revenue',
      editable: false,
      cell: 'number',
      formatter: Utils.CurrencyFormatter}]
    
    super(options)
    @listenTo(@controller, 'up-trending:index',=>
      @$el.find('ul.trending').children('li').removeClass('active')
      @$el.find('ul.trending a.up').parents('li').addClass('active')
    )

  events: =>
    csv_event = "click #{@options.content_selector} .export-csv"
    events = {}
    events[csv_event] = (e)->
      date = @controller.get_filter_params().date
      fileName = "up_trending_#{date}.csv"
      data =
        view: 'daily'
        date: date
      @export_csv($(e.target), fileName, data)
    events['click a.up'] = (e) ->
      $(e.target).parents('ul').children('li').removeClass('active')
      $(e.target).parents('li').addClass('active')
      @controller.trigger('trending:cleanup')
      selected_val = @$el.find('input[type=radio]:checked')
      if selected_val.length > 0
        @days = selected_val.val()
      else
        @days = 2
      @get_items(days: @days)
      false

    events['change input[type=radio]'] = (e) =>
      @days = $(e.target).val()
      @controller.trigger('trending:cleanup')
      @get_items(days: @days)

    events

  get_items: (data) =>
    if data? and data.days?
      days = parseInt(data.days)
    else
      days = 2

    if days == 2
      @$el.find('input[type=radio].two-days').attr('checked', 'checked')
    if days == 7
      @$el.find('input[type=radio].one-week').attr('checked', 'checked')
    if days == 14
      @$el.find('input[type=radio].two-week').attr('checked', 'checked')
    if days == 21
      @$el.find('input[type=radio].three-week').attr('checked', 'checked')
    if days == 28
      @$el.find('input[type=radio].four-week').attr('checked', 'checked')

    super(data)
    @days = days

  unrender: =>
    @clean_content()
    @content_area.find('.ajax-loader').hide()
    super()

  prepare_for_render: =>
    super()
    @$el.find('li.period-selector').css('display', 'block')
    @content_area.find('.ajax-loader').css('display', 'block')
   
  render: =>
    @$el.find('li.active').removeClass('active')
    @$el.find('li a.up').parents('li').addClass('active')
    super(@content_area)
    
  queryCell:  ->
    that = this
    class QueryCell extends Backgrid.CADQueryCell
      handleQueryClick: (e) ->
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = $(e.target).text()
        current_date = new Date(@controller.get_filter_params().date)
        min_days = if that.days == 2 then 5 else that.days
        that.controller.trigger('search:sub-content',
          query: query
          view: 'daily'
          show_only_series: ['query_count']
          enable_range:
            max_date: current_date.toString('yyyy-MM-dd')
            min_date: current_date.add(-min_days).days().toString('yyyy-MM-dd')
        )
        new_path = 'trending/up/query/' + encodeURIComponent(query) + '/days/' +
          that.days
        that.router.update_path(new_path)
      false
    QueryCell
