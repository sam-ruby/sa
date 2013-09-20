Searchad.Views.SearchComparison||= {}

class Searchad.Views.SearchComparison.IndexView extends Backbone.View
  initialize: (options) ->
    @controller = SearchQualityApp.Controller
    @router = SearchQualityApp.Router
    @controller.bind('content-cleanup', @unrender)
    @collection = new Searchad.Collections.QueryCatMetricsDailyCollection()
    @collection.bind('reset', @render_query_results)
    
    @query_form = @$el.find(options.form_selector)
    @before = @$el.find(options.before_selector)
    @after = @$el.find(options.after_selector)
    @comparison = @$el.find(options.comparison_selector)

  events:
    'click button.search': 'handle_search'

  form_template: JST['backbone/templates/query_comparison/form']

  active: false

  seriesTypes: [{
    column: "query_pvr"
    name: I18n.t('perf_monitor.product_view_rate_l')},
    {column: "query_atc"
    name: I18n.t('perf_monitor.add_to_cart_rate_l')},
    {column: "query_con"
    name: I18n.t('perf_monitor.conversion_rate_l')}]

  initRevQueryTable: (data) ->
    columns = [{name: 'query_revenue',
    label: I18n.t('search_analytics.revenue'),
    editable: false,
    cell: 'number',
    formatter: Utils.CurrencyFormatter},
    {name: 'query_count',
    label: I18n.t('search_analytics.queries'),
    editable: false,
    cell: 'integer'}]

    grid = new Backgrid.Grid(
      columns: columns
      collection: new Backbone.Collection(data)
    )
    grid


  initComparisonTable: (data) ->
    columns = [{name: 'query_pvr',
    label: I18n.t('perf_monitor.product_view_rate'),
    editable: false,
    cell: 'number'
    formatter: Utils.PercentFormatter},
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
    {name: 'query_revenue',
    label: I18n.t('search_analytics.revenue'),
    editable: false,
    cell: 'number',
    formatter: Utils.CurrencyFormatter},
    {name: 'query_count',
    label: I18n.t('search_analytics.queries'),
    editable: false,
    cell: 'integer'}]

    grid = new Backgrid.Grid(
      columns: columns
      collection: new Backbone.Collection(data)
    )
    grid

  generateChart: (title, series, dom) ->
    dom.highcharts(
      chart:
        type: 'funnel'
      credits:
        enabled: false
      title:
        text: title
        useHTML: true
        align: "center"
      plotOptions:
        funnel:
          dataLabels:
            color: 'black'
            distance: 2
            format: '<b>{point.name}</b> ({point.y:,.2f}%)'
        series:
          neckWidth: '30%'
          neckHeight: '25%'
      legend:
        enabled: false
      series: series)
  
  handle_search: =>
    data =
      query: @query_form.find('input.search-query').val()
      selected_week: @query_form.find('select').val()
      query_date: @query_form.find('input.datepicker').val()
    
    new_path = 'query_perf_comparison/query/' +
      encodeURIComponent(data.query) + '/wks_apart/' +
      data.selected_week + '/query_date/' + encodeURIComponent(data.query_date)
    
    @router.update_path(new_path)
    @get_items(data, false)
  
  get_items: (data, refresh_form=true) ->
    @clean_query_results()
    unless data
      data =
        query: ''
        selected_week: 1
        query_date: ''
    else
      data.query_date = decodeURIComponent(data.query_date)
      data.selected_week = parseInt(data.selected_week)
   
    if refresh_form
      $(@query_form).html(@form_template(data))
      @query_form.find('input.datepicker').datepicker()
      @active = true

    if data and data.query
      @query = data.query
      image =$('<img>').addClass('ajax-loader').attr(
        'src', '/assets/ajax_loader.gif').css('display', 'block')
      @before.find('.chart').append(image)
      @after.find('.chart').append(image.clone())
      @collection.get_items(data)

  render_query_results: =>
    before_data = @collection.first().get('before_week')
    after_data = @collection.first().get('after_week')
   
    if before_data.error == 1
      @render_error(@before.find('.chart'))
    else
      data = @process_data(before_data.data)
      dom = @before.find('.title')
      dom.append($('<i>').addClass('icon-backward'))
      dom.append($("<span class='h4 lpadding-one-em'>" +
        before_data.title + '</span>'))
      @render_chart(@query, data, @before.find('.chart'))
      @render_table(before_data.data, @before.find('.table'))

    if after_data.error == 1
      @render_error(@after.find('.chart'))
    else
      data = @process_data(after_data.data)
      dom = @after.find('.title')
      dom.addClass('pull-right')
      dom.append($("<span class='h4 rpadding-one-em'>" +
        after_data.title + '</div>'))
      dom.append($('<i>').addClass('icon-forward'))
      @render_chart(@query, data, @after.find('.chart'))
      @render_table(after_data.data, @after.find('.table'))

    if before_data.error == 0 and after_data.error == 0
      comparison_data =
        query_pvr: after_data.data.query_pvr - before_data.data.query_pvr
        query_con: after_data.data.query_con - before_data.data.query_con
        query_atc: after_data.data.query_atc - before_data.data.query_atc
        query_revenue: after_data.data.query_revenue -
          before_data.data.query_revenue
        query_count: after_data.data.query_count - before_data.data.query_count

      @comparison.append($('<i>').addClass('icon-resize-horizontal'))
      @comparison.append($('<span> Week over Week comparison </span>'))
      grid = @initComparisonTable(comparison_data)
      @comparison.append(grid.render().$el)

  process_data: (data) ->
    [{data: [
      {name: 'Product View Rate'
      y: data.query_pvr
      dataLabels:
        format: '<b>PVR</b> ({point.y:,.2f}%)'
      },
      {name: 'Add to Cart Rate'
      y: data.query_atc
      },
      {name: 'Conversion Rate'
      y: data.query_con
      }]}]

  render_error: (dom) ->
    dom.children().remove()
    dom.append($('<div class="alert alert-error">No Data available</div>'))

  render_title: (title, css_class, dom) ->
    dom.append($('<i>').addClass(css_class))
    dom.append($("<div class='h4'>" + title + '</div>'))

  render_chart: (title, data, dom) ->
    @generateChart(title, data, dom)
  
  render_table: (data, dom) =>
    grid = @initRevQueryTable(data)
    dom.append(grid.render().$el)
 
  unrender: =>
    @query_form.children().remove()
    @clean_query_results()
    @active = false

  clean_query_results: =>
    @before.highcharts().destroy() if @before.highcharts()
    @after.highcharts().destroy() if @after.highcharts()
    @comparison.children().remove()

    for el in [@before, @after]
      for sub_el in ['.title', '.chart', '.table']
        el.find(sub_el).children().remove()
