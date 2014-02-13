Searchad.Views.PoorPerforming ||= {}

class Searchad.Views.PoorPerforming.IndexView extends Backbone.View
  initialize: (options) =>
    _.bindAll(this, 'render', 'initTable')
    @trigger = false
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @collection = new Searchad.Collections.PoorPerformingCollection()
    @initTable()

    @$el.find('.ajax-loader').hide()
    
    @controller.bind('date-changed', =>
      @get_items(trigger: true) if @active)
    @controller.bind('content-cleanup', @unrender)
    
    @collection.bind('reset', @render)
    @collection.bind('request', =>
      @$el.children().not('.ajax-loader').remove()
      @$el.find('.ajax-loader').css('display', 'block')
      @controller.trigger('sub-content-cleanup')
      @controller.trigger('search:sub-tab-cleanup')
      @undelegateEvents()
    )

    Utils.InitExportCsv(
      this, "/poor_performing/get_search_words.csv")
    @undelegateEvents()
    @active = false

  events: =>
    'click .export-csv a': (e) ->
      date = @controller.get_filter_params().date
      fileName = "poor_performing_#{date}.csv"
      data =
        view: 'daily'
        date: date
      @export_csv($(e.target), fileName, data)
  
  gridColumns:  ->
    that = this
    class QueryCell extends Backgrid.CADQueryCell
      handleQueryClick: (e) ->
        Backgrid.CADQueryCell.prototype.handleQueryClick.call(this, e)
        query = $(e.target).text()
        that.controller.trigger('search:sub-content',
          query: query
          view: 'daily'
          # tab: Searchad.UserLatest.sub_tabs.current_tab
        )
        new_path = 'poor_performing/query/' +
          encodeURIComponent(query)
        that.router.update_path(new_path)
        false
    
    columns = [{
    name: 'query',
    label: I18n.t('query'),
    editable: false,
    cell: QueryCell},
    {name: 'revenue',
    label: I18n.t('search_analytics.revenue'),
    editable: false,
    cell: 'number',
    formatter: Utils.CurrencyFormatter},
    {name: 'query_count',
    label: I18n.t('search_analytics.queries'),
    editable: false,
    cell: 'integer'},
    {name: 'query_con',
    label: I18n.t('perf_monitor.conversion_rate'),
    editable: false,
    cell: 'number',
    formatter: Utils.PercentFormatter},
    {name: 'query_atc',
    label: I18n.t('perf_monitor.add_to_cart_rate'),
    editable: false,
    cell: 'number',
    formatter: Utils.PercentFormatter},
    {name: 'query_pvr',
    label: I18n.t('perf_monitor.product_view_rate'),
    editable: false,
    cell: 'number'
    formatter: Utils.PercentFormatter}]

    columns

  initTable: () =>
    @grid = new Backgrid.Grid(
      columns: @gridColumns()
      collection: @collection
    )
    
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )
  
  get_items: (data) =>
    @active = true
    @$el.find('.ajax-loader').css('display', 'block')
    @collection.get_items(data)
    @trigger = true

  unrender: =>
    @active = false
    @$el.children().not('.ajax-loader').remove()
    @$el.find('.ajax-loader').hide()
    @undelegateEvents()

  render_error: =>
    @$el.append( $('<span>').addClass(
      'label label-important').append("No data available"))

  render: =>
    return unless @active
    @$el.find('.ajax-loader').hide()
    return @render_error(' ') if @collection.size() == 0
    
    @$el.append( @grid.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @paginator.render().$el)
    @$el.append( @export_csv_button() )
    @delegateEvents()
    
    if @trigger
      @trigger = false
      @$el.find('td a.query').first().trigger('click')
    this
