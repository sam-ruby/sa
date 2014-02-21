Searchad.Views.Trending ||= {}

class Searchad.Views.Trending extends Backbone.View
  initialize: (options) =>
    @trigger = false
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    baseCols =  [
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

    if @gridCols and @gridCols.length > 0
      for col in baseCols
        @gridCols.push(col)
    else
      @gridCols = baseCols
    
    @initTable()
    @collection.bind('reset', @render)
    @collection.bind('request', @prepare_for_render)
    @controller.bind('date-changed', =>
      @get_items(trigger: true) if @active)
    @controller.bind('content-cleanup', @unrender)
    @listenTo(@controller, 'trending:cleanup', @clean_content)
    
    @active = false
  
  initTable: () =>
    @grid = new Backgrid.Grid(
      columns: @gridCols
      collection: @collection
      emptyText: 'No Data'
    )
    
    @paginator = new Backgrid.Extension.Paginator(
      collection: @collection
    )
  
  get_items: (data) =>
    @active = true
    @collection.get_items(data)
    @trigger = true

  prepare_for_render: =>
    @$el.css('display', 'block')
    @controller.trigger('sub-content-cleanup')
    @controller.trigger('search:sub-tab-cleanup')

  clean_content: =>
    @active = false
    @content_area.children().not('.ajax-loader').remove()
  
  unrender: =>
    @active = false
    @$el.hide()

  render: (div)=>
    return unless @active
    div.find('.ajax-loader').hide()
    if @collection.size() == 0
      div.prepend( @grid.render().$el)
      return
    else
      div.prepend(@paginator.render().$el)
      div.prepend(@grid.render().$el)
    div.append( @export_csv_button() ) unless div.find('.export-csv').length>0
    div.find('td a.query').first().trigger('click')
    this

